=head1 NAME

Math::Numbers - Methods for mathematical approaches of concepts of the number theory

=head1 SYNOPSIS

  use Math::Numbers;

  my $a = 123;
  my $b = 34;

  my $numbers = Math::Numbers->new($a, $b [, ...]);

  print "They are coprimes (relatively primes)!\n" if $numbers->are_coprimes;
  print "The greatest common divisor of these at least two numbers is ", $numbers->gcd;

  my $number = Math::Numbers->new($a);

  print "It is prime!\n" if $number->is_prime;

  my @divisors = $number->get_divisors;

  print "$a is divisor of $b!\n" if $number->is_divisor_of($b);


=head1 DESCRIPTION

Math::Numbers is quite a simple module on matters of programming. What
it's interesting is the focus and approach it is intended to be made from
the Number Theory basis for Perl beginners (like me) and also for young
mathematicians (like me).

The normal topics of Number Theory include divisibility, prime numbers
(which is separately intended to be covered by L<Math::Primes>),
congruences, quadratic residues, approximation for Real numbers,
diophantine equations, etc. and all this is intended to be convered by the
module on the concept on getting and setting values and also retriving
the proof methods.

=head1 METHODS

=cut

require 5;
package Math::Numbers;

use strict;
use warnings;
use List::Util qw(max);

our $VERSION = '0.000000001';

=head2 new

  # Some methods require more than only one argument.
  my $numbers = Math::Numbers->new($p, $q, ...);

  # Some methods require only one.
  my $number = Math::Numbers->new($p);

Create a L<Math::Numbers> object. Note that some of the methods will require
objects created with only one or a defined numbers of arguments.

=cut

sub new {
	my($this, @args) = @_;
	
	my $class = ref($this) || $this;

	return bless {
			numbers => \@args
	}, $class;
}

=head2 gcd

	my $gcd = $numbers->gcd;

Calculation of the Greatest Common Divisor. This is made by two different
methods which are described below: Bluto's algorithm and Euclidean
algorithm: The former is used when computing GCD for more than two
integers; the latter is used when getting the GCD for two numbers to
improve speed. See below for information on each.

=cut

sub gcd {
	my($self, @args) = @_;
	my @numbers = sort {$a < $b} @{$self->{'numbers'}};
	die "Math::Numbers: gcd requires at least two numbers argument from the object. By now.\n"
		if @numbers < 2;

	if(@numbers == 2) {
		&Euclidean_algorithm(@numbers);
	} else {
		&Bluto_algorithm(@numbers);
	}
}

=head2 Bluto_algorithm

You will mostly not require to call this method, but directly C<gcd()>.
Bluto's algorithm uses a brute force calculation used by mathematicians
to get divisors and then GCD also called Primality Test. Bluto takes some
spinaches stolen from Popeye and starts dividing m all the way through 2
to m/2.

=cut

# We'll need some spinach
sub Bluto_algorithm {
	my @numbers = @_;
        my @compare;

        foreach my $number(@numbers) {
                $number = abs $number;
                my @divisors;
                for my $i (1..$number) {
                        push(@divisors, $i) if $number % $i == 0;
                }
                push(@compare, @divisors);
        }

        my $count = @numbers;

        # Thanks for the tip to BinGOs from #perl at irc.freenode.net
        my %hash;
        $hash{$_}++ for @compare;
        my @repeats = grep {
                        $hash{$_} == @numbers
        } keys %hash;

        return max @repeats;
}	

=head2 Euclidean_algorithm

Euclid rocks. I have a very nice Budgerigar (L<http://en.wikipedia.org/wiki/Budgerigar>)
called the same in honor of him (have to upload a pic of him).

As of now, this algorithm is only computed on two integers. From the Wikipedia
entry: I<Given two natural numbers a and b: check if b is zero; if yes, a
is the gcd. If not, repeat the process using (respectively) b, and the
remainder after dividing a by b>. This is exactly what our method does.

=cut

# Euclid rocks!
sub Euclidean_algorithm {
	my @numbers = sort {$a < $b} @_;

	my $b = abs $numbers[0];
	my $c = abs $numbers[1];

	my $rem = $b % $c;
	
	return $c if $rem == 0;

	if($c == 0) {
		return $c;
	} else {
		&Euclidean_algorithm($c, $rem);
	}
}

=head2 is_divisor_of

  print "Yes, $p is divisor of $a...\n" if $number->is_divisor_of($a);

Let's see if the number from the object is a divisor of $a, which means
that the division $number/$a will return an integer (not necesarily a
natural). If it does, it'll return 1; 0, otherwise.

=cut

sub is_divisor_of {
	my($self, @args) = @_;
	my @number = @{$self->{'numbers'}};
	die "Math::Numbers: is_divisor_of requires one argument from the object!\n"
		if @number != 1;
	die "Math::Numbers: is_divisor_of requires one argument!\n"
		if @args != 1;
	
	$args[0] % $number[0] == 0 ? 1 : 0;
}

=head2 get_divisors

  my @divisors = $number->get_divisors;

What are the divisors of the number brought by the object? This only
includes the Natural numbers.

=cut

sub get_divisors {
	my($self, @args) = @_;
	my @number = @{$self->{numbers}};

	my @ret;

	{ my $i;
		for $i (2..$number[0]/2) {
			push(@ret, $i) if $number[0] % $i == 0;
		}
	}
	push(@ret, 1, $number[0]);
	return @ret;
}

=head2 is_prime

  print "$p is not prime!\n" unless $number->is_prime

Returns 0 or 1 if the number from the object is prime or not,
respectively. This method uses the, a bit slow, primality test.

=cut

# Primality testing!
# This may be a bit slowly with _big_ numbers...
sub is_prime {
	my($self, @args) = @_;

	my @number = @{$self->{numbers}};
	die "Math::Numbers: is_prime requires one argument from the object!\n"
		if @number != 1;

	for(my $i = 2; $i <= $number[0] - 1; $i++) {
		return 0 if($number[0] % $i == 0);
	}

	1;
}

=head2 are_coprimes

  print "They are coprimes because their GCD is 1!\n" if $numbers->are_coprimes;

Are the numbers from the object coprimes (relatively primes)? This means,
the GCD is 1; (a, b, c, ...) = 1. Returns 1 or 0.

=cut

sub are_coprimes {
	my($self, @args) = @_;
	my @numbers = @{$self->{numbers}};
	die "Math::Coprimes: are_coprimes requires at least two arguments!\n"
		if @numbers < 2;

	return 1 if &gcd($self, @numbers) == 1;
	0;
}

1;

__END__

=head1 DEPENDENCIES

You will need L<List::Util> to get C<Bluto_algorithm> to work.

=head1 TODO

Lots of things are still left. A few examples are:

=over

=item *

Admit any number of arguments from the object and returning
evaluations for each.

=item *

Adding a method for proofs.

=item *

More, more number theory!

=back

=head1 AUTHOR

David Moreno Garza, E<lt>damog@ciencias.unam.mxE<gt>

=head1 THANKS

Thanks go, as usual to the National Autonomous University of Mexico
(UNAM, Universidad Nacional Autónoma de México, L<http://www.unam.mx/>)
for providing such a beautiful career. Thanks also to Raquel
(L<http://www.maggit.com.mx>) for being my day-to-day
inspiration and special thanks to the I<#perl> at I<FreeNode> dudes and
Marco Antonio Manzo (L<http://www.unixmonkeys.com/amnesiac/blog/>)
and Gunnarcito Wolf (L<http://www.gwolf.org>).

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by David Moreno Garza

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

The Do What The Fuck You Want To public license also applies. It's
really up to you.

=cut
