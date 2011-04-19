<?php
function smarty_function_mtentrysnippet ( $args, &$ctx ) {
    $entry = $ctx->stash( 'entry' );
    if (! $entry ) return '';
    $data = $entry->snippet;
    if (! $data ) return '';
    $snippet = $ctx->mt->db()->unserialize( $data );
    $key = $args[ 'key' ];
    if (! $key ) $key = 'snippet';
    return $snippet[ $key ];
}
?>