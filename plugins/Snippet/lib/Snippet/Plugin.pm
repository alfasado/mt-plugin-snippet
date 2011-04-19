package Snippet::Plugin;

use strict;
use Encode;

sub pre_run {
    my $app = MT->instance;
    if ( $app->mode eq 'search_replace' ) {
        if ( my $search = $app->param( 'search' ) ) {
            my $plugin = MT->component( 'Snippet' );
            my $core = MT->component( 'core' );
            my $registry = $core->registry( 'applications', 'cms', 'search_apis', 'entry', 'search_cols' );
            $registry->{ snippet } = $plugin->translate( 'Snippet' );
            $app->param( 'search', MT::I18N::utf8_off( $search ) );
        }
    }
}

sub serarch_replace {
    my ( $cb, $app, $param, $tmpl ) = @_;
    if ( $app->mode eq 'search_replace' ) {
        if ( my $search = $app->param( 'search' ) ) {
            Encode::_utf8_on( $search );
            $param->{ search } = $search;
        }
    }
}

sub _hdlr_snippet {
    my ( $ctx, $args ) = @_;
    my $key = $args->{ key } || 'snippet';
    my $entry = $ctx->stash( 'entry' );
    my $data = $entry->snippet;
    require MT::Serialize;
    my $out = MT::Serialize->unserialize( $data );
    my $params = $$out;
    return $params->{ $key } || '';
}

sub preview_snippet {
    my ( $cb, $app, $entry, $param ) = @_;
    if (! $app->param( 'snippet_beacon' ) ) {
        return;
    }
    my $ref = ref $entry;
    if ( ( $ref eq 'MT::Entry' ) || ( $ref eq 'MT::Page' ) ) {
        my $data;
        my $q = $app->param();
        for my $key ( $q->param ) {
            if ( $key =~ /^snippet/ ) {
                my $value = $q->param( $key );
                $data->{ $key } = $value;
            }
        }
        require MT::Serialize;
        my $ser = MT::Serialize->serialize( \$data );
        $entry->snippet( $ser );
    }
    return 1;
}

sub save_snippet {
    my ( $cb, $app, $entry, $original ) = @_;
    if (! $app->param( 'snippet_beacon' ) ) {
        return;
    }
    my $data;
    my $q = $app->param();
    my $has_snippet;
    for my $key ( $q->param ) {
        if ( $key =~ /^snippet/ ) {
            $has_snippet = 1;
            my $value = $q->param( $key );
            $data->{ $key } = $value;
        }
    }
    if (! $has_snippet ) {
        return 1;
    }
    require MT::Serialize;
    my $ser = MT::Serialize->serialize( \$data );
    $entry->snippet( $ser );
    return 1;
}

sub insert_snippet {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component( 'Snippet' );
    my $prefs = 'entry_prefs';
    my $object_type = 'entry';
    if ( $param->{ object_type } eq 'page' ) {
        $prefs = 'page_prefs';
        $object_type = 'page';
    }
    my $data = $param->{ snippet };
    require MT::Serialize;
    my $out = MT::Serialize->unserialize( $data );
    my $params = $$out;
    foreach my $key ( keys %$params ) {
        $param->{ $key } = $params->{ $key };
    }
    my $snippet = $plugin->get_config_value( $object_type . '_snippet', 'blog:' . $param->{ blog_id } );
    $snippet .= '<input type="hidden" name="snippet_beacon" value="1" id="snippet_beacon" />';
    my $entry_prefs = $app->permissions->$prefs;
    my $show_snippet = 1 if $entry_prefs =~ /,snippet,/;
    push( @{ $param->{ field_loop } }, {
        field_id => 'snippet',
        lock_field => '0',
        field_name => 'snippet',
        show_field => $show_snippet,
        field_label => $plugin->translate( 'Snippet' ),
        label_class => 'top-label',
        required => '0',
        field_html => $snippet,
    } );
}

1;