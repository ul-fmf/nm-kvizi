classdef GeneratorNalog < handle
  % Razred za generiranje nalog za Moodle kvize.
  %
  % Dokumentacija za Moodle:
  %    https://docs.moodle.org/36/en/Numerical_question_type

  properties
    ime_kviza;  % Človeško ime kviza, npr. '1. kviz 2018/19'
    ime_naloge;   % Človeško ime naloge, npr. 'Naloga 1'.
    ime_datoteke;  % Ime npr. 'naloga1.xml'
    st_nalog;  % Koliko nalog naj se zgenerira.
    st_vprasanj;  % Koliko okenc za odgovor naj ima ta naloga.
    relativna_toleranca;  % Relativna toleranca napake študenta.
    generator_parametrov;  % Funkcija, ki generira parametre.
    koda_za_parametre;  % Koda, ki naj jo študent izvede na začetku.
    resitev_naloge;  % Tvoja funkcija, ki reši nalogo.
    uvod;  % Začetek naloge, ki vsebuje kodo za parametre in kaksne definicije za celo nalogo.'
    vprasanja = cell(1);  % Seznam vprašanj.
  end

  properties (SetAccess = private)
    rezultati;
    parametri;
  end

  methods
    function obj = GeneratorNalog(ime_kviza, ime_naloge, ime_datoteke)
      % Naredi generator nalog.
      %
      %  ime_naloge: Človeško ime naloge, npr. 'Naloga 1'.
      %  ime_datoteke: Ime datoteke brez '.xml' končnice, npr.
      %      'naloga1.' Privzeto enako kot ime_naloge.
      rng(0);
      assert(nargin >= 2, 'Podaj ime kviza in naloge!');
      if nargin < 3, ime_datoteke = [ime_naloge '.xml']; end

      obj.ime_kviza = ime_kviza;
      obj.ime_naloge = ime_naloge;
      obj.ime_datoteke = ime_datoteke;
    end

    function obj = generiraj(obj)
      obj.check();

      obj.parametri = cell(obj.st_nalog, 1);
      obj.rezultati = zeros(obj.st_vprasanj, obj.st_nalog);

      for i = 1:obj.st_nalog
        obj.parametri{i} = obj.nakljucna_koda_za_parametre();
        result = obj.resitev_naloge(obj.parametri{i});
        assert(isfloat(result), ['Rezultat naloge s parametri '...
          '"%s" ni vektor decimalnih števil.'], obj.parametri{i});
        n = numel(result);
        assert(n == obj.st_vprasanj, ['Rezultat bi moral imeti '...
          '%d elementov, dobil sem jih %d'], obj.st_vprasanj, n);
        obj.rezultati(:, i) = result(:);
      end

      if any(any(abs(obj.rezultati) < 1e-6))
        warning('Nekateri rezultati so zelo blizu 0!');
      end

      if ~all(all(isfinite(obj.rezultati)))
        warning('Nekateri rezultati niso končni!');
      end

      obj.shrani()
      fprintf('Datoteka "%s" uspešno ustvarjena.\n', obj.ime_datoteke);
    end
  end

  methods(Access=private)

    function t = nakljucna_koda_za_parametre(obj)
      c = count(obj.koda_za_parametre, '%%');
      k = count(obj.koda_za_parametre, '%') - 2*c;
      assert(k > 0, 'Začetna koda mora vsebovati vsaj eno dinamično polje.');
      params = zeros(k, 0);
      for i = 1:k, params(i) = obj.generator_parametrov(); end
      t = sprintf(obj.koda_za_parametre, params);
    end

    function check(obj)
      obj.check_string('Ime naloge', obj.ime_naloge);
      obj.check_string('Ime kviza', obj.ime_kviza);
      obj.ime_naloge = replace(obj.ime_naloge, '/', '//');  % v Moodlu so kategorije ločene z /, tako da če želimo / v imenu, ga moramo ponoviti dvakrat
      obj.ime_kviza = replace(obj.ime_kviza, '/', '//');
      obj.check_string('Ime datoteke', obj.ime_datoteke);
      obj.check_string('Koda za parametre', obj.koda_za_parametre);
      obj.check_string('Uvod naloge', obj.uvod);

      obj.st_nalog = obj.check_int('Število nalog', obj.st_nalog);
      obj.st_vprasanj = obj.check_int('Število vprašanj', obj.st_vprasanj);

      assert(0 < obj.relativna_toleranca, ...
        'Relativna toleranca mora biti pozitivna, dobil sem %d.', obj.relativna_toleranca);
      if obj.relativna_toleranca > 1e-2
        warning(['Relativna toleranca %g je precej visoka - tudi kakšen napačen rezultat bi lahko bil sprejet.'], obj.relativna_toleranca);
      end
      assert(0 < obj.st_nalog, 'Število decimalk mora biti pozitivno, dobil sem %d.');
      if obj.st_nalog > 200, warning('Število nalog %d je zelo veliko!', obj.st_nalog); end
      assert(0 < obj.st_vprasanj, 'Število vprašanj mora biti pozitivno, dobil sem %d.', obj.st_vprasanj);
      if obj.st_vprasanj > 10, warning('Število vprašanj %d je zelo veliko!', obj.st_vprasanj); end


      assert(iscell(obj.vprasanja), 'Vprašanja morajo biti cell dolžine %d.', obj.st_vprasanj);
      assert(numel(obj.vprasanja) == obj.st_vprasanj, 'Vprašanja morajo biti cell dolžine %d.', obj.st_vprasanj);
      obj.vprasanja = obj.vprasanja(:);

      for i = 1:obj.st_vprasanj
        obj.check_string(sprintf('Vprašanje %d', i), obj.vprasanja{i});
        obj.vprasanja{i} = ['<br><br>' obj.vprasanja{i} ' '];
      end

      assert(isa(obj.generator_parametrov, 'function_handle'),...
        'Generator parametrov mora biti funkcija, ki generira naključne parametre');
      assert(isa(obj.resitev_naloge, 'function_handle'),...
        'Resitev naloge mora biti funkcija, ki sprejme zacetno kodo in ',...
        'vrne vektor odgovor (za vsako vprasanje enega).');

    end

    function shrani(obj)
      fid = fopen(obj.ime_datoteke, 'w');
      assert(fid ~= -1, 'Ne morem odpreti datoteke ''%s''.', obj.ime_datoteke);

      fprintf(fid, '<?xml version="1.0"?>\n');
      fprintf(fid, '<quiz>\n');
      % question category
      fprintf(fid, '  <question type="category">\n');
      fprintf(fid, '    <category><text><![CDATA[$course$/%s/%s]]></text></category>\n', obj.ime_kviza, obj.ime_naloge);
      fprintf(fid, '  </question>\n\n');
      % description type question with question code inside
      fprintf(fid, '<!-- question: 1  -->\n');
      fprintf(fid, '  <question type="description">\n');
      fprintf(fid, '    <name><text><![CDATA[Uvod]]></text></name>\n');
      fprintf(fid, '    <questiontext format="html">\n');
      fprintf(fid, '      <text><![CDATA[uvod]]></text>\n');
      fprintf(fid, '    </questiontext>\n');
      fprintf(fid, '    <image></image>\n');
      fprintf(fid, '    <generalfeedback>\n');
      fprintf(fid, '      <text></text>\n');
      fprintf(fid, '    </generalfeedback>\n');
      fprintf(fid, '    <defaultgrade>0</defaultgrade>\n');
      fprintf(fid, '    <penalty>0</penalty>\n');
      fprintf(fid, '    <hidden>0</hidden>\n');
      fprintf(fid, '    <shuffleanswers>0</shuffleanswers>\n');
      fprintf(fid, '</question>\n\n');
      % insert questions into this category
      fprintf(fid, '  <question type="category">\n');
      fprintf(fid, '    <category><text><![CDATA[$course$/%s/%s]]></text></category>\n', obj.ime_kviza, obj.ime_naloge);
      fprintf(fid, '  </question>\n\n');
      % questions
      for i = 1:obj.st_nalog
        % question header
        fprintf(fid, '\n  <!-- question %d -->\n', i);
        fprintf(fid, '  <question type="cloze">\n');
        fprintf(fid, '    <name><text><![CDATA[Vprašanje %02d]]></text></name>\n', i);
        fprintf(fid, '    <questiontext>\n');
        fprintf(fid, '      <text><![CDATA[\n');

        % Uvod v nalogo
        fprintf(fid, 'Izvedite naslednje ukaze: <pre>%s</pre>\n', obj.parametri{i});
        fprintf(fid, '%s\n\n', obj.uvod);

        for j = 1:obj.st_vprasanj
          % Tekst vprašanja
          fprintf(fid, '%s\n', obj.vprasanja{j});
          % Okence za odgovor
          fprintf(fid, '{1:NUMERICAL:=%.16f:%.16f}\n\n', obj.rezultati(j, i), obj.relativna_toleranca*obj.rezultati(j, i));
        end

        % question footer
        fprintf(fid, '      ]]></text>\n');
        fprintf(fid, '    </questiontext>\n');
        fprintf(fid, '    <shuffleanswers>0</shuffleanswers>\n');
        fprintf(fid, '  </question>\n');
      end
      %
      fprintf(fid, '</quiz>\n');


      status = fclose(fid);
      assert(status ~= -1, 'Ne morem zapreti datoteke ''%s''.', obj.ime_datoteke);
    end
  end

  methods(Static, Access=private)
    function value = check_int(param, value)
      GeneratorNalog.check_nonempty(param, value)
      assert(isreal(value), '%s mora biti število, dobil sem tip ''%s''.', param, class(value));
      n = numel(value);
      assert(n == 1, '%s mora biti število, dobil sem %d vrednosti.', param, n);
      value = value(:);
      assert(mod(value, 1) == 0, '%s mora biti celo število, dobil sem %f.', param, value);
    end

    function check_string(param, value)
      GeneratorNalog.check_nonempty(param, value)
      assert(ischar(value), '%d mora biti niz znakov, dobil sem tip ''%s''.', param, class(value));
    end

    function check_nonempty(param, value)
      assert(~isempty(value), 'Podaj %s!', lower(param));
    end
  end
end
