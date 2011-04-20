<?php
function smarty_block_mtentrysnippetvars ( $args, $content, &$ctx, &$repeat ) {
    $localvars = array( 'snippet_option', '__counter__', '__snippet_option_max' );
    $entry = $ctx->stash( 'entry' );
    if (! $entry ) {
        $repeat = FALSE;
        return '';
    }
    if (! isset( $content ) ) {
        $ctx->localize( $localvars );
        $counter = 0;
        $ctx->__stash[ 'vars' ][ '__counter__' ] = 0;
    }
    $counter = $ctx->__stash[ 'vars' ][ '__counter__' ];
    $snippet_option = $ctx->stash( 'snippet_option' );
    $max = $ctx->stash( '__snippet_option_max' );
    if (! isset( $snippet_option ) ) {
        $data = $entry->snippet;
        if (! $data ) return '';
        $snippet = $ctx->mt->db()->unserialize( $data );
        $key = $args[ 'key' ];
        if (! $key ) $key = 'snippet';
        $snippet_option = $snippet[ $key ];
        if (! is_array( $snippet_option ) ) {
            $snippet_option = array( $snippet_option );
        }
        $max = count( $snippet_option );
        $ctx->stash( '__snippet_option_max', $max );
        $ctx->stash( 'snippet_option', $snippet_option );
        $ctx->__stash[ 'vars' ][ '__counter__' ] = 0;
    }
    if ( $counter < $max ) {
        $count = $counter + 1;
        $value = $snippet_option[ $counter ];
        $ctx->__stash[ 'vars' ][ 'snippet_option' ] = $value;
        $ctx->__stash[ 'vars' ][ '__counter__' ] = $count;
        
        $repeat = TRUE;
    } else {
        $ctx->restore( $localvars );
        $repeat = FALSE;
    }
    return $content;
}
?>