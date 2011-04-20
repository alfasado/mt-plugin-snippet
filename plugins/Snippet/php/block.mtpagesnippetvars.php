<?php
function smarty_block_mtpagesnippetvars ( $args, $content, &$ctx, &$repeat ) {
    require_once( 'block.mtpagesnippetvars.php' );
    return smarty_block_mtentrysnippetvars( $args, $content, $ctx, $repeat );
}
?>