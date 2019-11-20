function setup

gen = GeneratorNalog('1. kviz 2018/19', 'Naloga 1');
gen.st_nalog = 40;
gen.st_vprasanj = 2;
gen.relativna_toleranca = 1e-5;
gen.ime_datoteke = 'naloga1.xml';
gen.generator_parametrov = @rand;  % @() 2 + 3*rand(); ali @() randi([0 200], 1);

% Vsaka značka oblike '%x' je zamenjana z naključnim parametrom z ukazom sprintf.
gen.koda_za_parametre = 'a = %.16f;';  % 'seme = %d; rand(''seed'', seme); a = rand(1);'

gen.uvod = [
    'Naj bo $f(x) = \sinh(a+x)-ax-1$ za $x \in [-1, 1]$.'...
];

gen.vprasanja{1} = 'Pri katerem $x$ je $f(x) = 0$?';
gen.vprasanja{2} = [...
    'Ničlo $f$ iščemo s tangentno metodo. Za začetni približek '...
    'vzemimo $x_0 = 0.8$ in iteriramo, dokler ni razlika med zadnjima '...
    'približkoma manjša od $10^{-6}$. Koliko je zadnji približek?'];

gen.resitev_naloge = @resi_nalogo;
assignin('base', 'gen', gen)  % izvozimo v globalni namespace, da je na voljo tudi uporabniku

gen.generiraj();

end

function rezultati = resi_nalogo(koda_za_parametre)
    eval(koda_za_parametre);  % Izvedi začetno kodo, kot jo bodo študenti.
    % sem pride rešitev naloge

    f = @(x) sinh(a+x) - a*x - 1;
    odg1 = fzero(f, 0);

    df = @(x) cosh(a+x) - a;

    % lahko bi tudi poklicali zunanjo funkcijo
    x0 = 0.8;
    while 1
        x1 = x0 - f(x0)/df(x0);
        if abs(x1 - x0) < 1e-6, break; end
        x0 = x1;
    end

    odg2 = x1;
    rezultati = [odg1, odg2];  % vektor take dolžine kot je število vprašanj
end

