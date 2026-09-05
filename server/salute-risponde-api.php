<?php
/**
 * Plugin Name: Salute Risponde API
 * Description: Chat sanitaria e analisi informativa di documenti per Salute Risponde.
 * Version: 1.2.1
 * Author: Salute Risponde
 */

if (!defined('ABSPATH')) {
    exit;
}

add_action('rest_api_init', function () {
    register_rest_route('salute-risponde/v1', '/chat', [
        'methods'             => WP_REST_Server::CREATABLE,
        'callback'            => 'salute_risponde_chat',
        'permission_callback' => '__return_true',
    ]);

    register_rest_route('salute-risponde/v1', '/analyze-document', [
        'methods'             => WP_REST_Server::CREATABLE,
        'callback'            => 'salute_risponde_analyze_document',
        'permission_callback' => '__return_true',
    ]);

    register_rest_route('salute-risponde/v1', '/status', [
        'methods'             => WP_REST_Server::READABLE,
        'callback'            => function () {
            return new WP_REST_Response([
                'success' => true,
                'service' => 'Salute Risponde API',
                'version' => '1.2.1',
                'ai_configured' => salute_risponde_get_api_key() !== '',
                'chat'    => true,
                'vision'  => true,
            ], 200);
        },
        'permission_callback' => '__return_true',
    ]);
});

function salute_risponde_get_api_key() {
    $names = [
        'SALUTE_RISPONDE_OPENAI_API_KEY',
        // Compatibility with existing server configuration; never expose values.
        'SALUTE_CHIARA_OPENAI_API_KEY',
        'KINGO_MEDICO_OPENAI_API_KEY',
        'KINGO_OPENAI_API_KEY',
        'OPENAI_API_KEY',
    ];

    foreach ($names as $name) {
        if (defined($name)) {
            $value = trim((string) constant($name));
            if ($value !== '') {
                return $value;
            }
        }
    }

    foreach ($names as $name) {
        $value = getenv($name);
        if ($value !== false && trim((string) $value) !== '') {
            return trim((string) $value);
        }
    }

    return '';
}

function salute_risponde_extract_output_text($body) {
    $text = '';

    if (!isset($body['output']) || !is_array($body['output'])) {
        return '';
    }

    foreach ($body['output'] as $output_item) {
        if (!isset($output_item['content']) || !is_array($output_item['content'])) {
            continue;
        }

        foreach ($output_item['content'] as $content_item) {
            if (
                isset($content_item['type'], $content_item['text']) &&
                $content_item['type'] === 'output_text'
            ) {
                $text .= (string) $content_item['text'];
            }
        }
    }

    return trim($text);
}

function salute_risponde_error($message, $status, $code) {
    return new WP_REST_Response([
        'success' => false,
        'code'    => $code,
        'message' => $message,
    ], $status);
}

function salute_risponde_chat(WP_REST_Request $request) {
    $message = sanitize_textarea_field((string) $request->get_param('message'));
    $history = $request->get_param('history');

    if ($message === '') {
        return salute_risponde_error(
            'Scrivi un messaggio prima di inviare.',
            400,
            'empty_message'
        );
    }

    $api_key = salute_risponde_get_api_key();
    if ($api_key === '') {
        return salute_risponde_error(
            'Il servizio Salute Risponde non è ancora configurato sul server.',
            503,
            'service_not_configured'
        );
    }

    $input = [];
    if (is_array($history)) {
        foreach (array_slice($history, -12) as $item) {
            if (!is_array($item)) {
                continue;
            }

            $role = (isset($item['role']) && $item['role'] === 'assistant')
                ? 'assistant'
                : 'user';
            $content = isset($item['content'])
                ? sanitize_textarea_field((string) $item['content'])
                : '';

            if ($content !== '') {
                $input[] = [
                    'role'    => $role,
                    'content' => $content,
                ];
            }
        }
    }

    $input[] = [
        'role'    => 'user',
        'content' => $message,
    ];

    $instructions = implode("\n", [
        'Sei Salute Risponde, assistente sanitario informativo in lingua italiana.',
        'Devi essere pratico: per problemi lievi e compatibili con autogestione, l’utente deve capire cosa può fare concretamente.',
        'Non presentare mai una risposta come diagnosi definitiva e non sostituirti al medico.',
        'Non prescrivere farmaci soggetti a prescrizione e non modificare terapie già prescritte.',
        'Per sintomi comuni e lievi puoi spiegare anche opzioni da banco comunemente usate, evitando di proporre sempre lo stesso principio attivo.',
        'Scegli tra misure non farmacologiche e, quando appropriato, alternative OTC diverse in base al tipo di sintomo e alle controindicazioni note.',
        'Quando l’utente chiede cosa prendere, se hai informazioni sufficienti puoi indicare dosi GENERALI da foglietto illustrativo per adulti di farmaci da banco, specificando dose per singola assunzione, intervallo minimo tra le dosi, dose massima giornaliera e durata breve di automedicazione.',
        'Le dosi devono essere presentate come informazioni generali da etichetta o foglietto illustrativo, non come prescrizione personale.',
        'Prima di dare una dose verifica, quando rilevante, almeno età, eventuale gravidanza o allattamento, allergie, problemi renali, epatici o gastrici, anticoagulanti o altre terapie. Se mancano dati importanti, fai una breve domanda invece di inventare.',
        'Per bambini e adolescenti non dare dosi senza peso ed età; se non li conosci, chiedili.',
        'Non fornire dosaggi di farmaci con obbligo di prescrizione, antibiotici, sedativi, oppioidi o altri farmaci ad alto rischio.',
        'Quando esistono più opzioni ragionevoli, spiega brevemente perché una può essere più adatta dell’altra.',
        'Per ogni farmaco da banco menzionato indica le principali controindicazioni o situazioni in cui evitarlo, senza trasformare la risposta in un lungo elenco.',
        'Inserisci "Cosa puoi fare adesso:" con 2-4 azioni concrete e pertinenti.',
        'Inserisci "Per alleviare il disturbo:" quando pertinente, con opzioni pratiche e farmaci da banco appropriati.',
        'Inserisci "Nota scientifica:" con 2-4 frasi concrete sul meccanismo fisiologico, clinico o sull’evidenza rilevante.',
        'Se emergono segnali di allarme, peggioramento rapido o possibile emergenza, dai priorità alla sicurezza e indica chiaramente quando serve assistenza professionale.',
        'Non ripetere automaticamente “chiedi al medico” in ogni risposta: usalo quando serve davvero per sicurezza o quando mancano informazioni essenziali.',
        'RISPOSTE PIÙ CORTE E PIÙ UTILI: normalmente 120-180 parole.',
        'Struttura preferita: risposta diretta; "Cosa puoi fare adesso:"; "Per alleviare il disturbo:"; "Nota scientifica:"; segnali di allarme solo se pertinenti.',
        'Non usare Markdown con doppi asterischi. Non usare titoli prolissi.',
    ]);

    $response = wp_remote_post('https://api.openai.com/v1/responses', [
        'timeout' => 60,
        'headers' => [
            'Authorization' => 'Bearer ' . $api_key,
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json',
        ],
        'body' => wp_json_encode([
            'model'        => 'gpt-5.6',
            'instructions' => $instructions,
            'input'        => $input,
            'store'        => false,
        ]),
    ]);

    if (is_wp_error($response)) {
        return salute_risponde_error(
            'Errore di connessione al servizio AI.',
            502,
            'connection_error'
        );
    }

    $status = wp_remote_retrieve_response_code($response);
    $body = json_decode(wp_remote_retrieve_body($response), true);

    if ($status < 200 || $status >= 300) {
        $openai_message = '';
        if (
            is_array($body) &&
            isset($body['error']) &&
            is_array($body['error']) &&
            isset($body['error']['message'])
        ) {
            $openai_message = sanitize_text_field((string) $body['error']['message']);
        }

        return salute_risponde_error(
            $openai_message !== ''
                ? 'OpenAI: ' . $openai_message
                : 'Il servizio AI ha restituito un errore.',
            502,
            'ai_error'
        );
    }

    $reply = salute_risponde_extract_output_text($body);
    if ($reply === '') {
        return salute_risponde_error(
            'Salute Risponde non ha ricevuto una risposta valida.',
            502,
            'empty_response'
        );
    }

    return new WP_REST_Response([
        'success' => true,
        'reply'   => $reply,
    ], 200);
}

function salute_risponde_client_ip() {
    $ip = isset($_SERVER['REMOTE_ADDR']) ? (string) $_SERVER['REMOTE_ADDR'] : 'unknown';
    return preg_replace('/[^0-9a-fA-F:\.]/', '', $ip) ?: 'unknown';
}

function salute_risponde_vision_rate_limit() {
    $key = 'sr_vision_' . md5(salute_risponde_client_ip());
    $count = (int) get_transient($key);
    if ($count >= 10) {
        return false;
    }

    set_transient($key, $count + 1, HOUR_IN_SECONDS);
    return true;
}

function salute_risponde_analyze_document(WP_REST_Request $request) {
    if (!salute_risponde_vision_rate_limit()) {
        return salute_risponde_error(
            'Hai effettuato troppe analisi in poco tempo. Riprova più tardi.',
            429,
            'rate_limited'
        );
    }

    $files = $request->get_file_params();
    $file = isset($files['document']) && is_array($files['document'])
        ? $files['document']
        : null;

    if (!$file || empty($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
        return salute_risponde_error(
            'Seleziona o fotografa prima un documento.',
            400,
            'missing_document'
        );
    }

    if (!empty($file['error'])) {
        return salute_risponde_error(
            'Il caricamento della foto non è riuscito.',
            400,
            'upload_failed'
        );
    }

    $size = isset($file['size']) ? (int) $file['size'] : 0;
    if ($size < 1 || $size > 10 * MB_IN_BYTES) {
        return salute_risponde_error(
            'La foto deve avere una dimensione massima di 10 MB.',
            413,
            'file_too_large'
        );
    }

    $allowed_mimes = [
        'jpg|jpeg|jpe' => 'image/jpeg',
        'png'          => 'image/png',
        'webp'         => 'image/webp',
    ];

    $checked = wp_check_filetype_and_ext(
        $file['tmp_name'],
        isset($file['name']) ? sanitize_file_name($file['name']) : 'documento.jpg',
        $allowed_mimes
    );

    $mime = isset($checked['type']) ? (string) $checked['type'] : '';
    if (!in_array($mime, array_values($allowed_mimes), true)) {
        return salute_risponde_error(
            'Formato non supportato. Usa JPG, PNG oppure WEBP.',
            415,
            'unsupported_format'
        );
    }

    $bytes = file_get_contents($file['tmp_name']);
    if ($bytes === false || $bytes === '') {
        return salute_risponde_error(
            'Non è stato possibile leggere la foto.',
            400,
            'unreadable_document'
        );
    }

    $api_key = salute_risponde_get_api_key();
    if ($api_key === '') {
        return salute_risponde_error(
            'Il servizio di analisi non è ancora configurato sul server.',
            503,
            'service_not_configured'
        );
    }

    $instructions = implode("\n", [
        'Sei Salute Risponde, assistente sanitario informativo in lingua italiana.',
        'Leggi la foto di un esame, referto, certificato, ricetta o documento sanitario e spiegala con parole semplici.',
        'Non inventare testo, numeri, date o valori non chiaramente leggibili.',
        'Se la foto è sfocata, tagliata o non è un documento sanitario, dichiaralo subito e chiedi una nuova foto.',
        'Distingui chiaramente ciò che è scritto nel documento dalle tue spiegazioni generali.',
        'Non formulare diagnosi definitive e non modificare terapie.',
        'Se sono presenti valori fuori intervallo, riportali con unità e intervallo visibile e spiega brevemente cosa possono indicare in generale.',
        'Se il documento contiene indicazioni urgenti o segnali di possibile emergenza, evidenziali subito.',
        'Usa questa struttura: "Cosa dice il documento:", "Spiegato semplicemente:", "Cosa verificare:".',
        'Mantieni la risposta chiara e normalmente entro 250 parole.',
        'Non usare Markdown con doppi asterischi.',
    ]);

    $payload = [
        'model'        => 'gpt-5.6',
        'instructions' => $instructions,
        'input'        => [[
            'role'    => 'user',
            'content' => [
                [
                    'type' => 'input_text',
                    'text' => 'Analizza e spiegami questo documento sanitario.',
                ],
                [
                    'type'      => 'input_image',
                    'image_url' => 'data:' . $mime . ';base64,' . base64_encode($bytes),
                ],
            ],
        ]],
        'store' => false,
    ];

    $response = wp_remote_post('https://api.openai.com/v1/responses', [
        'timeout' => 90,
        'headers' => [
            'Authorization' => 'Bearer ' . $api_key,
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json',
        ],
        'body' => wp_json_encode($payload),
    ]);

    if (is_wp_error($response)) {
        return salute_risponde_error(
            'Errore di connessione al servizio di analisi.',
            502,
            'connection_error'
        );
    }

    $status = wp_remote_retrieve_response_code($response);
    $body = json_decode(wp_remote_retrieve_body($response), true);
    if ($status < 200 || $status >= 300) {
        return salute_risponde_error(
            'Il servizio di analisi ha restituito un errore.',
            502,
            'vision_error'
        );
    }

    $explanation = salute_risponde_extract_output_text($body);
    if ($explanation === '') {
        return salute_risponde_error(
            'Non è stato possibile leggere il documento. Prova con una foto più nitida.',
            502,
            'empty_analysis'
        );
    }

    return new WP_REST_Response([
        'success'     => true,
        'explanation' => $explanation,
    ], 200);
}
