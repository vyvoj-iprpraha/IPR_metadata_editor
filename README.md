**# upgrade_blank**## Metadatový editor ArcGIS PRO upravený o custom položky IPR.


Repozitár obsahuje zdrojový kód úprav ArcGIS PRO metadatového editoru. Zdrojom informácii pre úpravy editoru bolo [Custom Metadata Editor Toolkit](https://github.com/Esri/arcgis-pro-metadata-toolkit) + konzultácie s ArcData.

-------------------------

### Nové položky v metadatovom editore ArcGIS PRO:
- Overview>Topics&Kewords>Téma INSPIRE(INSPIREstatus) - jednoduché select menu
- Overview>Topics&Kewords>Téma IPR(IPSstatus) - jednoduché select menu
- Overview>Topics&Kewords>Jev ÚAP 2020(UAPstatus) - jednoduché select menu
- Overview>Topics&Kewords>Jev ÚAP(UAP2024status) - jednoduché select menu
- Overview>Topics&Kewords>Klíčové slovo IPR(IPRkeywordstatus) - jednoduché select menu
- Overview>Topics&Kewords>Doplňkové klíčové slovo IPR(INSPIREstatus) - mnohonásobné select menu
- Overview>Topics&Kewords>Klíčové slovo GEMET(GEMETstatus) - jednoduché select menu
- Overview>Topics&Kewords>Datový sklad(INSPIREstatus) - mnohonásobné select menu
- Overview>Topics&Kewords>Kategorie otevřených dat(INSPIREstatus) - mnohonásobné select menu
- Resource>Fields>Details>Attribute>Publish this attribute(verejne) - check box

### Vysvetlivky
Cesta k položke v metadatovom editore>názov položky v editore(názov položky v xml) - typ položky v editore


### Upravené položky v metadatovom editore ArcGIS PRO:
- Overview>Topics&Kewords>Other IPR Keywords(keyword) - text box

Bola zrušená povinnosť byť required. Toto bolo dosiahnuté zakomentovaním nasledujúcej časti v `config.daml`:<br/>
`<for xpath="/metadata/dataIdInfo/themeKeys">
<exists xpath="bag[. != '']" ref="bag,.,themeKeywords" />
</for>`
Odstránením komentáru sa položke vráti pôvodná funkčnosť - opäť bude vyžadované jej vyplnenie ako povinné.

-------------------------

### Tieto súbory vznikly: 
- `\Pages\Custom_Datastore.xaml`
- `Pages\Custom_DatastoreBase.xaml`
- `\Pages\Custom_OpendataCategory.xaml`
- `\Pages\Custom_OpendataCategoryBase.xaml`
- `\Pages\Custom_OtherIPRKeyword.xaml`*
- `\Pages\Custom_OtherIPRKeywordBase.xaml`*

Okrem samotných xaml súborov k nim vznikli aj C# podsúbory.<br/>
*Toto sú xamly pre Doplňkové klíčové slovo IPR (názov v editore v PRO), nemýliť si s Other IPR Keywords (názov v editore v PRO). Other IPR Keywords je definované pomocou Theme Keys v Keywords.xaml

-------------------------

### Následovné súbory boli upravené
- `\IPRMetadata\Properties\Definitions.resx`
- `\IPRMetadata\Properties\Resources.resx`
- `\Pages\Keywords.xaml`
- `\IPRMetadata\Config.daml`*
- `\Pages\EntityAttribute.xaml` **

Pre jednoduchšiu identifikáciu boli všetky upravené/pridané časti v xaml súboroch oddelené ako na začiatku tak na konci týmto symbolom:
`<!--************************************************************-->`

*Bola iba definovaná cesta na xslt, zrušená povinnosť mat vyplnené Other IPR Keywords(viď nižšie), pribudla položka `<viewerXslt>` a to ktoré stránky editoru sa majú aktualizovať spolu s aktualizáciou ARcGIS PRO(viď nižšie)<br/>
<br/>
** Súbor kde pribudol check box

-------------------------

V  `\Pages` bol ponechaný CustomPage.xaml, ak by bola potrebná prázdna stránka pre ďalšie metadatové polia v budúcnosti.

-------------------------

Aktualizácia jednotlivých stránok editora sa kontroluje pomocou Config.daml, kde custom hlavička znamená, že upgrady pre danú stránku zapezpečuje IPR. V prípade výmeny hlavičky na ESRI default bude daná stránka aktualizovaná automaticky vtedy keď sa povyšuje ArcGIS PRO. 

Príklad:<br/>
Custom (súčasný stav): `<page class="IPRMetadata.Pages.MTK_ItemInfo">`<br/>
ESRI Default: `<page class="ArcGIS.Desktop.Metadata.Editor.Pages.ItemInfo">`

-------------------------
Okrem úprav editora bolo nutné vytvoriť tiež xslt transformáciu tak aby bolo možné validovať metadáta oproti INSPIRE validátoru:
[https://geoportal.gov.cz/web/guest/validate/metadata/](https://geoportal.gov.cz/web/guest/validate/metadata/)

Cesta na xslt súbor(pre IPR):
`[cesta_k_souboru]\ArcGIS_2ISO19139_CustomExporter.xslt`<br/>
<br/>
Tento je tiež dostupný v zložke v projekte:
`\IPRMetadata\CustomStylesheets\ArcGIS_2ISO19139_CustomExporter.xslt`<br/>
Aj tu boli pre jednoduchšiu identifikáciu všetky upravené/pridané časti oddelené týmto symbolom:<br/>
`<!--************************************************************-->`

XSLT umožňuje export z ArcGIS XMLka(to je to čo vidíš keď v Pročku dáš View metadata) do XMLka v tvare ktorý vyhovuje INSPIRE. ArcGIS PRO>Catalog view, zvoľ feature class a v Catalog ribbone hore je možnosť Export. Zvoľ a v The type of metadata to export: zvoľ IPRMetadata Metadata Toolkit Editor.

Validátor, ktorý využíva xslt transformáciu je možné nájsť (pre IPR): <br/>
`[cesta_k_souboru]\CustomToolbox.atbx\INSPIREvalidation`
<br/>
Tento je tiež dostupný... tbd

