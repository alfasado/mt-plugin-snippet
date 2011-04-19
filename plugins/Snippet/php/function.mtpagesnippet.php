<?php
function smarty_function_mtpagesnippet ( $args, &$ctx ) {
    require_once( 'function.mtentrysnippet.php' );
    return smarty_function_mtentrysnippet ( $args, $ctx );
}
?>