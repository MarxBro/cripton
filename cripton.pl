#!/usr/bin/perl
######################################################################
# Cripton -> huevada encriptadora, inspirada/afanada de:
# http://fayland.googlecode.com/svn/trunk/script/misc/dencrypt.pl
######################################################################
use strict;
use feature "say";
use Getopt::Std;
use Pod::Usage;
use autodie;
use Crypt::CBC;
use File::Slurp;

=pod

=head1 SYNOPSIS

Script para encriptar y decriptar archivos de texto plano.

=cut

my %opts = ();
getopts('rdho:k:f:',\%opts);

=pod

=head2 Forma de uso:

Necesita minimamente que se especifique un tipo de operacion y un key para ello.

El key es -nada mas, nada menos- un password, cualquier tipo de palabra puede funcionar
(siempre y cuando no se la olviden al momento de decriptar!).

Al nombre del archivo de salida se le agrega ".encriptado" y ".decriptado",
a menos que se especifique la opcion b<-r> para b<sobreescribir> el archivo original.

Con la opcion -c, la salida de la operacion no es un archivo sino la terminal. Si no
se especifica un archivo mediante el switch -f ni la opcion -c, el programa falla y termina
infelizmente y con vertigo en el upite.

=over

=item * -o [e||d]       Operacion: Puede ser I<e>ncriptar o I<d>ecriptar. b<[requerido]> 

=item * -k [key]        Clave. b<[requerido]> 

=item * -f [archivo]    El archivo sobre el que efectuar las operaciones. b<[opcional]> 

=item * -r              Reescribir e archivo original. b<[opcional]>

=item * -c              Tirar toda la salida a STDOUT. NO excluye la opcion -f. b<[opcional]>

=item * -d              Debugging flag.

=item * -h              Ayudas. (Esto!) 

=back

=cut

######################################################################
# Main
######################################################################
if ($opts{h}){
    ayudas();
    exit 0;
} elsif (not ($opts{o} and $opts{k})){
    #ayudas();
    die "Error: Faltan parametros. Se requieren siempre 3.\n";
} elsif ($opts{o} !~ /e|d/){
    #ayudas();
    die "Error: La operacion no es valida/reconocida. Tiene que ser e (Encriptar) o d (Decriptar).";
} elsif (not(-e $opts{f})){
    #ayudas();
    die "Error: el archivo $opts{f} no existe o no es valido.";
} else {
    # la papa es esto.
    my $debug      = $opts{d} || 0;
    my $operacion  = $opts{o};
    my $key        = $opts{k};
    my $archivo    = $opts{f} || "nop";
    my $reescribir = $opts{r};
    my $salida_tty = $opts{c};
    
    # prevenir debugs que ensucien la consola
    $debug = 0 if $salida_tty;
    
    say "$operacion  $key  $archivo" if $debug;

    my $cipherin = Crypt::CBC->new(
        -key    => $key,
        -cipher => 'Blowfish'
    );
    # Leer archivo
    my $data = read_file("$archivo");
    my ( $data_pa_escribir, $archivo_pa_escribir );
    
    $archivo_pa_escribir = $archivo;

    # Definir que es lo que hay que hacer
    if ( $operacion eq 'e' ) {
        $data_pa_escribir    = $cipherin->encrypt($data);
        unless ($archivo eq 'nop'){ $archivo_pa_escribir .= '.encriptado' unless $reescribir };
    } else {
        $data_pa_escribir    = $cipherin->decrypt($data);
        unless ($archivo eq 'nop'){ $archivo_pa_escribir .= '.decriptado' unless $reescribir };
    }
    
    # Escribir todo de vuelta
    write_file( $archivo_pa_escribir, $data_pa_escribir );
    
    # Salida a la consola.
    say $data_pa_escribir if $salida_tty;
    
    # Final.
    if ( -e $archivo_pa_escribir ) {
        say "Archivo $archivo_pa_escribir guardado correctamente. Final Feliz.";
    }
    exit 0;
}
######################################################################
# Subs
######################################################################
sub ayudas {
    pod2usage(-verbose=>3);
}

=pod

=head1 Autor y Licencia.

Programado por B<Marxbro> aka B<Gstv> en el 2015. Distribuir bajo 
la licencia WTFPL: I<Do What the Fuck You Want To Public License>.

Zaijian.

=cut
