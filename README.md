# Kvizi pri numeričnih metodah

Ta dokument opisuje kako uporabljati skripto za generiranje
vprašanj za ustvarjanje kvizov na spletni učilnici Moodle
za preverjanje znanja pri numeričnih predmetih na FMF.

Kvizi so sestavljeni iz več nalog (običajno 4), vsaka naloga ima lahko eno ali
več (običajno dve) vprašanj. V vsaki nalogi nastopa parameter in vsak študent
dobi naloge z drugimi vrednostmi parametra. To pomeni, da je npr. za 40
študentov in kviz s 4 nalogami potrebno zgenerirati 4 zbirke vprašanj, v vsaki
zbirki je 40 nalog istega tipa z različnimi vrednostmi parametrov. Vsak študent
potem na kvizu dobi po eno naključno nalogo iz vsake zbirke.

## Uporaba razreda za generiranje XML nalog

Za uporabo kode za generiranje kvizov potrebujete Matlab (gotovo deluje na verziji 2017a,
vendar najverjetneje tudi na nekaj starejših in novejših).

1. Skopiraj skripto `test_generator.m` in jo preimenuj npr. v `naloga1.m`. Imeti mora dostop do
   razreda `GeneratorNalog` (lahko tudi datoteko `GeneratorNalog.m` skopiraš v isto mapo ali pa
   uporabiš ukaz `addpath`.

1. Nastavi metapodatke: ime kviza, število vprašanj, število študentov, toleranco, izhodno datoteko, itd... Nato
   nastavi naključno generiranje podatkov, napiši besedilo nalog in rešitev. Vse rešitve se
poženejo na podatkih, ki jih bodo dobili študenti, tako da lahko preveriš delovanje, se pa vsaka
rešitev (če ne uporabljaš globalnih spremenljivk) požene neodvisno od ostalih.

1. Poženi datoteko `naloga1.m`, ki zgenerira datoteko `naloga1.xml` (oz. kakor je bilo nastavljeno),
   ki jo potrebujemo za spletno učilnico.

1. Ponovi za vse naloge, ki pa si naj imajo enako ime kviza.

## Novosti

* ne potrebujete Mathematice, samo vključite eno datoteko v Matlabu
* ena datoteka za definicijo naloge, ena datoteka s podatki za Moodle
* kategorije se avtomatsko uvozijo, tako da jih ni treba ustvarjati ročno
* boljša podpora za generiranje naključnih podatkov, ki ne vključujejo `rng(seed)` funkcije
* manj možnosti za napake, saj se rešitev vsake generirane naloge požene znotraj funkcije neodvisno
  od ostalih (ne morejo te motiti druge spremenljivke, ali spremenljivke iz prejšnje iteracije)
  in z izvedeno točno kodo, ki jo bodo dobili študenti, kar zagotovi, da dejansko rešuješ problem z
  enakimi podatki (in se ne zmotiš npr. pri izpisovanju zaradi premalo decimalk).
* več preverjanja, da je število odgovorov enako številu besedil podnalog,
da so odgovori končna decimalna števila ne preblizu 0, ...

## Ustvarjanje novega kviza

Pred ustvarjanjem novega kviza poskrbite, da ste za vse naloge zgenerirali XML datoteke.

Na spletni učilnici izberite na levi meni "Zbirka vprašanj" in nato "uvozi". Izberi format "Moodle
XML", ne potrebujete pa nobenih drugih nastavitev, saj je kljukica "pridobi podatke iz datoteke"
privzeto označena in poskrbi za vse ostalo. Kliknete "Uvozi" in vprašanja se uvozijo. Enako ponovite
za vse ostale 4 datoteke.

Sedaj lahko naredite nov kviz preko "Vključi urejanje / dodaj dejavnost ali vir / kviz".
Tu je potrebno nastaviti

* časovna uskladitev: 60 min (omogoči), odprti poskusi naj se zaključijo in oddajo avtomatično (omogoči)
* postavitev: nova stran: vsakih 5 vprašanj (da bodo vse naloge na eni strani)
* obnašanje vprašanja: kako se vprašanja vedejo: prilagojen način (brez odbitkov)
* možnosti pregleda: pravilni odgovor (onemogoči)
* dodatne omejitve pri poskusih: zahtevaj geslo: potrebno je nastaviti geslo, ki ga bodo študenti izvedeli v predavalnici

Nato se gre na "Shrani in prikaži" in nato "Uredi kviz" (da dodamo še vprašanja).

Preko menija "Dodaj / Dodaj naključno vprašanje / kategorijo z ustrezno nalogo / Dodaj izbrano vprašanje" dodamo
vsako nalogo. Nato se popravi točkovanje in se vsaki nalogi da 2.5 točke (morda je treba vnesti
decimalko s piko ali vejico, odvisno od nastavitev jezika). Nato kliknemo "Shrani". Stran se ne zapre, zato moramo
potem ročno iti nazaj na kviz, da ga lahko testiramo.

## Napake

Ko se vprašanja uvozijo iz XML datotek jih dobite prikazana na zaslonu. Prvo vprašanje ima vedno besedilo
"uvod", ostala pa morajo imeti pravilno prikazan LaTeX (če ste ga uporabili) z nekaj polji oblike `{#1}` za rezultate.
Če po uvozu pri besedilu nalog opazite kakšno napako, morate uvožena vprašanja zbrisati, ponovno
zgenerirati pravilno XML datoteko in jo ponovno uvoziti. Vprašanja najlažje izbrišete tako, da
izberete "Naprej", jih označite in spodaj kliknete "Izbriši".

Če ste se zmotili v imenu kategorije morate najprej izbrisati vsa vprašanja v njej,
nato na izbrisati še kategorijo. Kategorijo lahko izbrišete preko menija "Zbirka vprašanj / Kategorije" s
klikom na `x` zraven kategorije.

Če so nastavitve kviza napačne, jih lahko uredite pred kvizom.  Ko kviz že ima vnešena vprašanja,
gumb "Uredi kviz" na kvizu izigne, vendar je še vedno na voljo spodaj levo, na podobni lokaciji kot
uvoz vprašanj.  Med kvizom večino nastavitev ni možno urejati, če pa se ureja nastavitve (npr.
časovna omejitev, geslo) morajo študenti osvežiti stran ali pa zapustiti in se vrniti v kviz, da
registrira spremembo.

## Zgodovina

Besedilo zgoraj je povzeto po dokumentu, ki ga je Bor Plestenjak sestavil za Seminar NA dne 11. 11. 2015
in je na voljo na USMAOŠ spletni učilnici.

Sam generator kvizov, ki je bil originalno napisan v kombinaciji Mathematice in Matlaba izvira iz FE, prek
Emila Žagarja, Andreja Muhiča, Bora Plestenjaka in Jureta Slaka, do trenutne kompaktnejše Matlab verzije.


## Naprednejša uporaba

Parametri razreda `GeneratorNalog` so:

* parametri konstruktorja: 2 niza, ime kviza in ime naloge. V Moodlu bo ob uvozu ustvarjena
  kategorija z imenom kviza in podkategorija z imenom naloge.
* `st_nalog`: število zgenenriranih naključnih nalog, mora biti večje kot število študentov,
  sicer se bodo naloge ponavljale.
* `st_vprasanj`: koliko vprašanj (okenc za rezultate) bo imela ta naloga
* `relativna_toleranca`: odgovor študenta bo veljal za pravilnega, če je njegova relativna napaka
  pod to toleranco
* `ime_datoteke`: ime zgenerirane datoteke (priporočljiva je končnica `.xml`.
* `generator_parametrov`: function handle, ki ne sprejme argumentov in ob vsakem
  klicu vrne eno naključno število
  Primeri: `@rand` za parametre enakomerno med 0 in 1, `@() randi([0 200], 1)`
za celoštevilske parametre med 0 in 200, `@() 2 + 3*rand()` za parametre med 2
in 5. S tem parametrov kontrolirate porazdelitev parametrov in ne njihovega
števila.

* `koda_za_parametre`: niz znakov z začetno kodo, ki jo izvede študent, kjer
  mora biti vsaj en naključen paramter

  Niz mora vsebovati polja oblike `%x`, ki se prek `sprintf` zamenjajo za
  zaporednimi rezultati funkcije `generator_parametrov`. Prek polj lahko
  specificiramo tudi število izpisanih decimalk, npr. `%.2f`. Nič ni narobe, če za
  lažjo berljivost izpišemo manj decimalk, saj bo tudi naša rešitev videla število
  zgolj kot `1.34`, saj `eval`-a točno ta niz s parametri.

  Primeri:
  - `a = %.16f;`: en parameter na 16 decimalk
  - `x = [%g, %g, %g];` vektor treh števil, izpisanih v "najlepši obliki"
  - `B = [%.2f, %.2f; %.2f, %.2f];` naključna 2x2 matrika
  - `c = %f; d = %f; e = c+2; M = e*ones(3, 3);` dva naključna parametra in dve predefinirani
    spremenljivki

* `uvod`: besedilo z uvodom za vsa vprašanja
* `vprasanja`: cell array dolžine kolikor je vprašanj z opisom pozameznega vprašanja
* `resitev_naloge`: function handle na rešitev naloge, ki kot parameter sprejme en niz z začetnimi
  parametri, od kjer s pomočjo `eval` lahko dobi enake začetne podatke, kot jih bo videl študent.

Po klicu metode `generiraj()` lahko v spremenljivki `gen.rezultati` pogledate izračunane rezultate.


