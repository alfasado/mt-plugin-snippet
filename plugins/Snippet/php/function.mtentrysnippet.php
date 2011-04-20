<?php
function smarty_function_mtentrysnippet ( $args, &$ctx ) {
    $entry = $ctx->stash( 'entry' );
    if (! $entry ) return '';
    $data = $entry->snippet;
    if (! $data ) return '';
    $snippet = $ctx->mt->db()->unserialize( $data );
    $key = $args[ 'key' ];
    if (! $key ) $key = 'snippet';
    $value = $snippet[ $key ];
    if ( is_array ( $value ) ) {
        $glue = $args[ 'glue' ];
        if (! $glue ) $glue = ',';
        return implode( $glue, $value );
    }
    return $snippet[ $key ];
}
?>