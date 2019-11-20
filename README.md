# Kvizi pri numeričnih metodah

Ta dokument opisuje kako uporabljati skripto za generiranje
vprašanj za ustvarjanje kvizov na spletni učilnici Moodle
za preverjanje znanja pri numeričnih predmetih na FMF.

## Uporaba razreda za geneiranje XML nalog

1. Skopiraj skrpto `test_generator.m` in jo preimenuj npr. v `naloga1.m`. Imeti mora dostop do
   razreda `GeneratorNalog` (lahko tudi datoteko `GeneratorNalog.m` skopiraš v isto mapo ali pa
   uporabiš ukaz `addpath`.

1. Nastavi metapodatke: ime kviza, število vprašanj, število študentov, toleranco, izhodno datoteko, itd... Nato
   nastavi naključno generiranje podatkov, napiši besedilo nalog in rešitev. Vse rešitve se
poženejona podatkih, ki jih bodo dobili študenti, tako da lahko preveriš delovanje, se pa vsaka
rešitev (če ne uporabljaš globalnih spremenljivk) požene neodvisno od ostalih.

1. Poženi datoteko `naloga1.m`, ki zgenerira datoteko `naloga1.xml` (oz. kakor je bilo nastavljeno),
   ki jo potrebujemo za spletno učilnico.

## Ustvarjanje novega kviza

Pred ustvarjanjem novega kviza poskrbite, da ste za vse naloge zgenerirali XML datoteke.

Na spletni učilnici izberite na levi meni "Zbirka vprašanj" in nato "uvozi". Izberi format "Moodle
XML", ne potrebujete pa nobenih drugih nastavitev, saj je kljukica "pridobi podatke iz datoteke"
privzeto označena in poskrbi za vse ostalo. Kliknete "Uvozi" in vprašanja se uvozijo. Enako ponovite
za vse ostale 4 datoteke.

Sedaj lahko naredite nov kviz preko "Vključi urejanje / dodaj dejavnost ali vir / kviz"

TODO: https://ucilnica1718.fmf.uni-lj.si/pluginfile.php/30497/mod_resource/content/0/Navodila%20za%20pripravo%20kvizov.pdf

## Napake

Ko se vprašanja uvozijo jih dobite prikazana na zaslonu. Prvo vprašnaje ima vedno besedilo
"uvod", ostala pa morajo imeti pravilno prikazan LaTeX (če ste ga uporabili) z nekaj polji oblike `{#1}` za rezultate.
Če po uvozu pri besedilu nalog opazite kakšno napako, morate uvožena vprašanja zbrisati, ponovno
zgenerirati pravilno XML datoteko in jo ponovno uzoviti. Vprašanja najlažje izbrišete tako, da
izberete "Naprej", jih označite in spodaj kliknete "Izbriši".

Če ste se zmotili v imenu kategorije morate najprej izbrisati vsa vprašanja v njej,
nato na izbrisati še kategorijo. Kategorijo lahko izbrišete preko menija "Zbirka vprašanj / Kategorije" s
klikom na `x` zraven kategorije.


## Zgodovina:

TODO
