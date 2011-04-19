package Snippet::Plugin;

use strict;

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