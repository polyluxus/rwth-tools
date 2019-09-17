[Dies ist die (lose) Übersetzung der englischen Version.](mol_struc_en.md)

---


## Preliminarien

Ich benutze den Ansatz für jeden Satz an Optimierungen ein Verzeichnis zu benutzen.
Meist läuft das auf ein Verzeichnis pro Molekül und Methode hinaus, 
in welchen dann alle abgeleiteten Rechnungen zu finden sind.

Zum Beispiel, für den Protonentransfer zwischen dem Hydronium ion und Ammoniak,

H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>, 

könnte ein Verzeichnissbaum wie folgt aussehen:

```
.
├── README
├── ammonia
│   ├── g16-b3lyp
│   │   ├── b3lypsvp.opt.com
│   │   ├── < ... >
│   │   └── b3lypsvp.start.xyz
│   ├── g16-bp86
│   │   ├── bp86svp.opt.com
│   │   ├── < ... >
│   │   └── bp86svp.start.xyz
│   └── g16-pbe0
│       ├── pbe0svp.opt.com
│       ├── < ... >
│       └── pbe0svp.start.xyz
├── ammonium
│   ├── g16-b3lyp
│   │   ├── b3lypsvp.opt.com
│   │   ├── < ... >
│   │   └── b3lypsvp.start.xyz
│   ├── g16-bp86
│   │   ├── bp86svp.opt.com
│   │   ├── < ... >
│   │   └── bp86svp.start.xyz
│   └── g16-pbe0
│       ├── pbe0svp.opt.com
│       ├── < ... >
│       └── pbe0svp.start.xyz
├── hydronium
│   ├── g16-b3lyp
│   │   ├── b3lypsvp.opt.com
│   │   ├── < ... >
│   │   └── b3lypsvp.start.xyz
│   ├── g16-bp86
│   │   ├── bp86svp.opt.com
│   │   ├── < ... >
│   │   └── bp86svp.start.xyz
│   └── g16-pbe0
│       ├── pbe0svp.opt.com
│       ├── < ... >
│       └── pbe0svp.start.xyz
└── water
    ├── g16-b3lyp
    │   ├── b3lypsvp.opt.com
    │   ├── < ... >
    │   └── b3lypsvp.start.xyz
    ├── g16-bp86
    │   ├── bp86svp.opt.com
    │   ├── < ... >
    │   └── bp86svp.start.xyz
    └── g16-pbe0
        ├── pbe0svp.opt.com
        ├── < ... >
        └── pbe0svp.start.xyz
```

Die Art der Ordnung erleichtert es Dateien die zueinander gehören zu gruppieren,
was wiederun Zeit beim Suchen spart und einen besseren Kontext bereit stellt.

Wenn man einen Reaktionsmechanismus entwickelt, sollte man einen
vorläufigen Pfad (oder Arbeitsversion) benutzen, dessen Numerierung dann
im Verlauf der Forschung referenziert werden kann.

Für ein Projekt wie in  
"[Why does cyclopropane react with bromine?](https://chemistry.stackexchange.com/q/10653/4945)",
könnte das wie folgt aussehen:

```
.
├── README
├── prelim_0010_react_cycprop
│   └── g16-opt-bp86
├── prelim_0020_react_dibrom
│   └── g16-opt-bp86
├── prelim_0030_ts_adduct
│   └── g16-opt-bp86
├── prelim_0040_ts_bromonium
│   └── g16-opt-bp86
├── prelim_0050_prod_chain
│   └── g16-opt-bp86
├── prelim_0060_etc___
│   └── g16-opt-bp86
└── prelim_0070
    └── g16-opt-bp86
```

Fügt den Verzeichnissen immer Datein bei (z.B. `README`) die erklären,
was sie enthalten.

Später kann man die vorläufige Numerierung umbenennen,
zum Beispiel mit 'soft links' `ln -s`:

```
.
├── README
├── fin_01_cycloprop -> prelim_0010_react_cycprop/
├── fin_02_br2 -> prelim_0020_react_dibrom/
├── fin_03_ts -> prelim_0040_ts_bromonium/
├── fin_04_dibrom-1-3-propane -> prelim_0050_prod_chain/
├── prelim_0010_react_cycprop
├── prelim_0020_react_dibrom
├── prelim_0030_ts_adduct
├── prelim_0040_ts_bromonium
├── prelim_0050_prod_chain
├── prelim_0060_etc___
└── prelim_0070
```

Das Inkrement 10 in der vorläufigen Numerierung erlaubt es zwischen einzelnen Schritten,
wenn notwendig, weitere Rechnungen einzufügen.

# Einfache Optimierung der Molekülstruktur

Die Molekülstruktur wird häufig auch *Geometrie* genannt,
demnach wird die Optimierung dieser auch *Geometrieoptimierung* genannt.

Das Folgende ist eine (kurze) Liste, welche beschreibt wie man von
einer geratenen/ generierten Startstruktur zur finalen, optimierten Struktur gelangt.


1. Erstellt eine Datei mit der Molekülstruktur in Cartesischen Koordinaten (`*.xyz`).

   Es erfordert ein bisschen Training ein gute Struktur zu erstellen, aber viele Programme,
   wie z.B. Chemcraft, haben auch Datenbanken mit Fragmenten.
   Falls Gaussview der Editor Eurer Wahl ist, dann gibt es noch ein paar [Anmerkungen zu Gaussview (in Englisch)](notes_gv_en.md).
   Für einfache Moleküle lassen sich oft auch Strukturen im Internet finden, z.B.
   [ChemSpider](http://www.chemspider.com/), [PubChem](https://pubchem.ncbi.nlm.nih.gov/search/).
   Mit einem [SMILES](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system) code
   und [Open Babel](http://openbabel.org) kann man auch eine Struktur erstellen.
   Für Ethanol ist der SMILES Code `CCO` 
   (vgl. [PubChem CID 702](https://pubchem.ncbi.nlm.nih.gov/compound/ethanol#section=Canonical-SMILES)),
   dann generiert der folgende Befehl eine Struktur in Cartesischen Koordinaten:
   ```
   ~/comp_chem/ $ obabel -:'CCO' -oxyz --gen3d -Oopt.start.xyz
   ```
   Die Option `-:` nimmt einen SMILES Code als Input an,
   `-o` wählt das Ausgabeformat (hier Xmol, Cartesische Koordinaten),
   `--gen3d` weißt es an 3D Koordinaten zu schreiben,
   und `-O` wählt die Ausgabedatei (vgl. [Open Babel Wiki](http://openbabel.org/wiki/Main_Page)).

   Manchmal funktioniert das auch für komplexe Moleküle,
   leider selten für Metallorganische Verbindungen, 
   da ionische Bindungen nicht beschrieben werden (vgl. [Fußnoten](#footnotes)).
   
   In diesem Beispiel soll die Datei `bp86svp.start.xyz` heißen.

2. Erstellt eine Input Datei. Man sollte wissen was in einer solchen Datei steht,
   daher ist es ratsam das auch einmal mit einem ganz normalen Editor zu schreiben.
   Hilfreich ist da Online-Handbuch von [Gaussian](http://gaussian.com/).
   Für eine *sehr einfache* Optimierung mit BP86/def2-SVP, 
   sähe dieser Schritt mit meinem Skript wie folgt aus (vgl. [Fußnoten](#footnotes)):
   ```
   ~/comp_chem/ $ g16.prepare -R'#P BP86/def2-SVP/W06' -r'OPT(MaxCycle=100)' -j'bp86svp.opt' bp86svp.start.xyz
   ```
   Die erstellte Datei heißt dann `bp86svp.opt.com`.
  
   Eine Übersicht über die Optionen der Skripte gibt es als
   [pdf Datei](https://github.com/polyluxus/tools-for-g16.bash/blob/master/docs/)
   im [tools-for-g16](https://github.com/polyluxus/tools-for-g16.bash) Paket.

3. Die Datei muss nun an das 'Queueing System' übergeben werden.
   Auch hier sollte man wissen was man tut, und das auch einmal von Hand gemacht haben.
   Mein Skript setzt jedoch viele Variablen und erleichtert so das Arbeiten sehr.
   In diesem Fall:
   ```
   ~/comp_chem/ $ g16.submit -p12 -m4000  bp86svp.opt.com
   ```
   Es wird eine neue, modifizierte Input Datei generiert: `bp86svp.opt.gjf`, die bereits die wichtigen Variablen
   für Gaussian enthält, außerdem wird ein Skript erstellt, welche alle notwendigen Informationen
   für die Queue enthält, es heißt `bp86svp.opt.bsub.bash` (für den Fall `bsub-rwth`).

   Welche Parameter man vernünftiger Weise setzt erkennt man mit etwas Erfahrung,
   man sollte lediglich darauf achten nicht mehr anzufordern als möglich ist.
   (Die hier gewählten p12, m4000 sollten für mittelgroße Moleküle gut reichen.)

4. Wenn die Rechnung fertig ist (man bekommt wahrscheinlich eine E-Mail), gibt es die folgenden Output Dateien:
   - `bp86svp.opt.log`: die Ausgabedatei von Gaussian
   - `bp86svp.opt.chk`: die 'Checkpoint' Datei (wichtig für weitere Rechnungen)
   - `bp86svp.opt.bsub.bash.e<number>`: Fehlermeldungen des Queueing Systems
   - `bp86svp.opt.bsub.bash.o<number>`: Standardmeldungen des Queueing Systems

   Prüft die Ausgabedatei auf Fehlermeldungen. Am Ende sollte *Normal termination* stehen:
   ```
   ~/comp_chem/ $ tail bp86svp.opt.log
   ```
   Suche bei Optimierungen auch nach *stationary point found*:
   ```
   ~/comp_chem/ $ grep 'Stationary point found' -B7 -A3  bp86svp.opt.log

   ```
   Schaut die optimierte Struktur mit einem Betrachtungsprogramm an.

5. Erstellt einen Input für eine Frequenzrechnung **im selben** Verzeichniss (benutzt `%OldChk` zum einlesen der Checkpoint Datei),
   oder mit meinem Skript:
   ```
   ~/comp_chem/ $ g16.freqinput bp86svp.opt.gjf
   ```
   Es wird `bp86svp.opt.freq.com` erstellt, welche man abschicken kann:
   ```
   ~/comp_chem/ $ g16.submit -p12 -m24000  bp86svp.opt.freq.com
   ```
   Frequenzrechnungne benötigen mehr Arbeitsspeicher, ca. 2 GB pro Kern sollte meis ausreichen.

6. Ähnlich wie zuvor erhält man die Output Datein.
   Schaut euch die Gaussian Ausgabedatei in einem Molekülbetrachter an und inspiziert die Frequenzen,
   wenn es keine imaginäre Mode gibt habt ihr ein *lokales* Minimum gefunden;
   wenn genau eine imaginäre Mode vorhanden ist, handelt es sich um einen Übergangszustand.
   Wiederholt die vorangegangenen Schritte, bis ihr das Optimierungsziel erreicht habt.

7. Durchsucht die Output Datein nach den wichtigen Energien und tabelliert diese um
   Energiedifferenzen, oder Barrieren, usw. zu bestimmen.
   Auch hier gibt es ein geeignetes Skript, welches einen Teil der Arbeit übernimmt:
   ```
   ~/comp_chem/ $ g16.getfreq -V3  bp86svp.opt.freq.log
   ```

8. Formattiert die Checkpoint Datei und schreibt die optimierte Struktur in eine Datei.
   Gaussians Checkpoint Dateien sind plattformabhängig, da sie im Binärformat sind.
   Des Weiteren können viele andere Programme formattierte Checkpoit Datein lesen,
   daher sollte man sie immer erstellen.
   Das Öffnen eine einzelnen (optimierten) Struktur ist viel schneller als
   die Ausgabedatei zu öffen in einem Moleküleditor.

   Das folgende Kommando erledigt beides:
   ```
   ~/comp_chem/ $ g16k2xyz  bp86svp.opt.freq.chk
   ```
   Die erstellten Datein heißen `bp86svp.opt.freq.fchk` und `bp86svp.opt.freq.xyz`.
   Mit der Option `-a` werden alle `*.chk` formattiert.

Wenn alles erledigt und ausgewertet ist, das ist meißt die eigentliche Schwierigkeit,
z.B. ganz am Ende des Projekts, sollte man binäre Checkpoint Datein löschen, denn sie brauchen sehr viel Platz.

## Übung

### Protonierung

Berechnet die Gibbs Energien für die oben gegebene Reaktion,

H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>, 

mit den Functionalen BP86, PBE0, TPSS, und den Basissätzen STO-3G, 6-31+G(d,p), def2-SVP, def2-TZVPP.

Zum Vergleich gibt es [die Ergebnisse (in Englisch)](exercises/protonation.md) mit ein paar weiteren Tipps.


---
### Fußnoten

1. Einige funktionieren zwar einigermaßen, z.B. Natriumethanolat (`CC[O-].[Na+]`), andere wiederum gar nicht, z.B.
   [Tris(ethylenediamin)cobalt(III)chlorid](https://pubchem.ncbi.nlm.nih.gov/compound/407049):
   `C(C[NH-])[NH-].C(C[NH-])[NH-].C(C[NH-])[NH-].[Co].[Cl-].[Cl-].[Cl-]`.
  
2. Ein angemessenes Theorieniveau zu wählen ist nicht gerade trivial da man einiges berücksichtigen muss,
   zum Beispiel Präzision, Leistung und Geschwindigkeit.
   Ich habe einen längeren Artikel (in Englisch) darüber geschrieben:
   [DFT Functional Selection Criteria](https://chemistry.stackexchange.com/a/27418/4945).

   Das Beispielkommando beutzt das Theorieniveau DF-BP86/def2-SVP, jedoch mit einem Zusatz.
   Zur Erinnerung:
   ```
   ~/comp_chem/ $ g16.prepare -R'#P BP86/def2SVP/W06' -r'OPT(MaxCycles=100)' -j'bp86svp.opt' bp86svp.start.xyz
   ```
   Der `-R` Schaltier von g16.prepare setzt die Basis-Route auf `#P BP86/def2SVP/W06`. 
   Die verschiedenen Teile bedeuten Folgendes:

   - Das `#P` wählt die ausführliche Ausgabe aus ([G16-Handbuch](http://gaussian.com/route/?tabid=1)),
   andere Möglichkeiten sind `#N` (normal) und` #T` (*terse*, knapp).
   - Als Methode ist `BP86` ausgewählt, wodurch das Austauschfunktional `B` und das Korrelationsfunktional `P86` ausgewählt wird.
   Es sind viele andere [Funktionale](http://gaussian.com/dft/) implementiert.
   - Für das Beispiel habe ich den Basissatz def2-SVP gewählt; beachte: das Keyword ist ohne Bindestrich.
   In [Gaussian](http://gaussian.com/basissets/) sind viele Basissätze verfügbar, und weitere können definiert werden,
   das ist jedoch etwas für fortgeschrittenere Benutzer (und eine Übung für einen anderen Tag).
   - Zusätzlich fordert diese Route *Density fitting*, 
   manchmal auch als *Resolution-of-the-Identity* oder kurze RI-Näherung bezeichnet,
   mit dem Hilfsbasissatz `W06` (weitere Informationen im [Handbuch](http://gaussian.com/basissets/?tabid=2)),
   was die Berechnung beschleunigen sollte.
   Dies ist auch über das Keyword [`DensityFit`/`DenFit`](http://gaussian.com/densityfit/) ansteuerbar;
   und wird daher in der Theorie allgemein mit DF abgekürzt.
   
   Der `-r` Schalter des Skripts fügt der Route weitere Keywords hinzu.
   In diesem speziellen Fall fordern wir eine Optimierung ([`OPT`](http://gaussian.com/opt/)) mit höchstens 100 Zyklen an.
   
   Die `-j` Option wählt einen Jobnamen für die Rechnung aus, von welchem auch die Dateinamen abgeleitet werden.
   
   Das letzte Argument ist die Datei mit der Molekülstruktur, hier im Xmol-Format.
   Es werden auch einige andere Formate erkannt, aber das ist auch etwas für einen späteren Zeitpunkt.

___version___: 2019-09-17-1200
