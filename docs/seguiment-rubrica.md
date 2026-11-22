# Seguimiento de la rúbrica individual

Fuente: `rubrica/rubrica-individual.html` (plantilla `tpl-845545c`). Solo se listan las **96 actividades activas**; las desactivadas por el profesor no cuentan.

**Cómo usarlo:** cuando una actividad tenga su evidencia citada en el `.md` indicado, se marca aquí `[x]` y en el HTML se pone *«Feta correctament»*. Si el profesor la revisa, se marca además *«El professor l’ha revisada»* con su resultado.

El texto de la actividad está copiado **tal cual** del HTML (en valenciano) para encontrarla rápido.

## Resumen por RA (Apte = obligatoria · Apte+ = ampliación)

| RA | Apte | Apte+ | Para el 10 hace falta |
|---|---|---|---|
| FDM-RA1 | 10 | 5 | a27, a28, a29, a30, a127 |
| FDM-RA4 | 4 | 1 | a57 |
| ISO-RA1 | 45 | 3 | a84, a129, a149 |
| ISO-RA3 | 16 | 5 | a105, a107, a108, a109, a110 |
| ISO-RA6 | 11 | 4 | a123, a124, a125, a126 |


## Tasca 0 · Muntatge de l’entorn de proves

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [x] | a17 | Apte | FDM-RA1 | Preparar l’entorn propi de proves. | F4 | 05-recursos |
| [x] | a18 | Apte | FDM-RA1 | Identificar-ne els recursos físics i justificar-ne les limitacions. | F1 | 02-inventari |
| [x] | a127 | Apte+ | FDM-RA1 | Documentar l’entorn propi en Markdown i Git: esquema de VM, recursos i problemes resolts. | F7 | README + 05-recursos + 10-incidencies |

## Tasca 2 · Equips i perifèrics

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [x] | a19 | Apte | FDM-RA1 | Inventariar l’equip de classe i el de casa. | F1 | 02-inventari |
| [x] | a20 | Apte | FDM-RA1 | Comparar els equips i identificar colls de botella. | F1 | 02-inventari |
| [x] | a21 | Apte | FDM-RA1 | Proposar solucions ajustades al maquinari disponible. | F1 | 02-inventari |
| [x] | a27 | Apte+ | FDM-RA1 | Executar tests de memòria, disc i xarxa en l’equip de classe i en el de casa. | F1 | 02-inventari |
| [x] | a28 | Apte+ | FDM-RA1 | Registrar l’eina, les condicions i els resultats dels tests. | F1 | 02-inventari |
| [x] | a29 | Apte+ | FDM-RA1 | Confirmar o descartar amb dades els colls de botella previstos. | F1 | 02-inventari |

## Tasca 4 · Disseny físic i lògic

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [x] | a128 | Apte | ISO-RA1 | Dibuixar l’esquema de xarxa individual, el muntatge virtual i les adreces previstes. | F2 | 04-disseny |
| [x] | a148 | Apte | ISO-RA1 | Indicar la configuració de cada interfície i la LAN 192.168.XX.0/24 segons el lloc a l’aula; la WAN pot obtindre la IP per DHCP (adaptador pont o millor NAT). | F2 | 04-disseny |
| [x] | a129 | Apte+ | ISO-RA1 | Implementar la xarxa individual i comprovar la connectivitat amb ping, traceroute i taules d’encaminament. | F3 | 04-disseny |
| [x] | a149 | Apte+ | ISO-RA1 | Aportar evidències de ping, traceroute, taula d’encaminament i configuració de les interfícies entre les VM i cap a l’exterior. | F3 | 04-disseny |

## Tasca 5 · Instal·lació i comunicacions

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [x] | a78 | Apte | ISO-RA1 | Comprovar els requisits i l’origen de les imatges d’instal·lació (arquitectura, fiabilitat de l'origen, etc). Verificar la integritat de les imatges quan el fabricant publique el mecanisme | F0 | 03-sistemes |
| [x] | a79 | Apte | ISO-RA1 | Abans de ficar en producció, realitzar l'actualització i comprovació del correcte funcionament del sistemes instal·lats. | F4 | 06-installacions |
| [x] | a203 | Apte | ISO-RA1 | MikroTik: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F3 | 06-installacions |
| [x] | a204 | Apte | ISO-RA1 | MikroTik: configurar l’usuari o usuaris d’administració. | F3 | 06-installacions |
| [x] | a205 | Apte | ISO-RA1 | MikroTik: configurar els paràmetres de xarxa de les interfícies WAN i LAN. | F3 | 06-installacions |
| [x] | a206 | Apte | ISO-RA1 | MikroTik: permetre l’accés a Internet des dels equips de la LAN. | F3 | 06-installacions |
| [x] | a207 | Apte | ISO-RA1 · ISO-RA6 | MikroTik: provar una connexió permesa i una bloquejada i interpretar el registre. | F3 | 06-installacions |
| [x] | a208 | Apte | ISO-RA3 | MikroTik: guardar la còpia de configuració o sistema al servidor de còpies. | F5 | 09-copies-contingencia |
| [x] | a209 | Apte | ISO-RA3 | MikroTik: provocar una errada controlada i comprovar la recuperació de l’equip o la part afectada. | F5 | 09-copies-contingencia |
| [x] | a210 | Apte | ISO-RA1 | OPNsense: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F3 | 06-installacions |
| [x] | a211 | Apte | ISO-RA1 | OPNsense: configurar l’usuari o usuaris d’administració. | F3 | 06-installacions |
| [x] | a212 | Apte | ISO-RA1 | OPNsense: configurar els paràmetres de xarxa de les interfícies WAN i LAN. | F3 | 06-installacions |
| [x] | a213 | Apte | ISO-RA1 | OPNsense: permetre l’accés a Internet des dels equips de la LAN. | F3 | 06-installacions §9 (evidencia `client-linux-tiempos-descarga-instalador.png` + `…red-y-salida-internet.png`) |
| [x] | a214 | Apte | ISO-RA1 · ISO-RA6 | OPNsense: provar una connexió permesa i una bloquejada i interpretar el registre. | F3 | 06-installacions |
| [x] | a215 | Apte | ISO-RA3 | OPNsense: guardar la còpia de configuració o sistema al servidor de còpies. | F5 | 09-copies-contingencia |
| [x] | a216 | Apte | ISO-RA3 | OPNsense: provocar una errada controlada i comprovar la recuperació de l’equip o la part afectada. | F5 | 09-copies-contingencia |
| [x] | a217 | Apte | ISO-RA1 | GNU/Linux amb nftables: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F3 | 06-installacions |
| [x] | a218 | Apte | ISO-RA1 | GNU/Linux amb nftables: configurar l’usuari o usuaris d’administració. | F3 | 06-installacions |
| [x] | a219 | Apte | ISO-RA1 | GNU/Linux amb nftables: configurar els paràmetres de xarxa de les interfícies WAN i LAN. | F3 | 06-installacions |
| [x] | a220 | Apte | ISO-RA1 | GNU/Linux amb nftables: permetre l’accés a Internet des dels equips de la LAN. | F3 | 06-installacions |
| [x] | a221 | Apte | ISO-RA1 · ISO-RA6 | GNU/Linux amb nftables: provar una connexió permesa i una bloquejada i interpretar el registre. | F3 | 06-installacions |
| [x] | a222 | Apte | ISO-RA3 | GNU/Linux amb nftables: guardar la còpia de configuració o sistema al servidor de còpies. | F5 | 09-copies-contingencia |
| [x] | a223 | Apte | ISO-RA3 | GNU/Linux amb nftables: provocar una errada controlada i comprovar la recuperació de l’equip o la part afectada. | F5 | 09-copies-contingencia |
| [x] | a224 | Apte | ISO-RA1 | TrueNAS: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F4 | 06-installacions |
| [x] | a225 | Apte | ISO-RA1 | TrueNAS: configurar l’usuari o usuaris d’administració. | F4 | 06-installacions |
| [x] | a226 | Apte | ISO-RA1 | TrueNAS: configurar els paràmetres de xarxa de les interfícies. | F4 | 06-installacions |
| [x] | a227 | Apte | ISO-RA3 | TrueNAS: preparar un disc addicional o, si no és possible, una partició addicional per a les còpies dels equips crítics. | F4 | 06-installacions |
| [x] | a228 | Apte | ISO-RA1 | Proxmox: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F4 | 06-installacions |
| [x] | a229 | Apte | ISO-RA1 | Proxmox: configurar l’usuari o usuaris d’administració. | F4 | 06-installacions |
| [x] | a230 | Apte | ISO-RA1 | Proxmox: configurar els paràmetres de xarxa de les interfícies. | F4 | 06-installacions |
| [x] | a231 | Apte | ISO-RA3 | Proxmox: copiar les configuracions o imatges necessàries al servidor corresponent i justificar què es copia i què no. | F5 | 09-copies-contingencia |
| [x] | a232 | Apte | ISO-RA1 | Proxmox: configurar el clúster amb els nodes disponibles; si no hi ha nodes suficients, registrar el disseny o la simulació autoritzada. | F4 | 06-installacions |
| [x] | a235 | Apte | ISO-RA1 · ISO-RA6 | Proxmox: executar la migració d’un contenidor i una VM entre nodes disponibles. La migració de una VM haurà de ser d'un sistema ubuntu server o debian sense entorn gràfic per a que siga més ràpid. | F4 | 06-installacions |
| [x] | a236 | Apte | ISO-RA6 | Proxmox individual: mesurar temps i espai de la migració de VM i contenidor, interpretar-los i valorar millores. | F4 | 06-installacions |
| [x] | a237 | Apte | ISO-RA1 | Windows Server 2025: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F4 | 06-installacions |
| [x] | a238 | Apte | ISO-RA1 | Windows Server 2025: configurar l’usuari o usuaris d’administració. | F4 | 06-installacions |
| [x] | a239 | Apte | ISO-RA1 | Windows Server 2025: configurar els paràmetres de xarxa de les interfícies. | F4 | 06-installacions |
| [x] | a240 | Apte | ISO-RA3 | Windows Server 2025: copiar les configuracions o imatges necessàries al servidor corresponent i justificar què es copia i què no. | F5 | 09-copies-contingencia |
| [x] | a241 | Apte | ISO-RA1 | Windows Server 2025: explicar què és un domini i què aporta la gestió centralitzada a l’empresa. | F4 | 06-installacions |
| [x] | a242 | Apte | ISO-RA1 | Servidors GNU/Linux d’infraestructura: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F4 | 06-installacions |
| [x] | a243 | Apte | ISO-RA1 | Servidors GNU/Linux d’infraestructura: configurar l’usuari o usuaris d’administració. | F4 | 06-installacions |
| [x] | a244 | Apte | ISO-RA1 | Servidors GNU/Linux d’infraestructura: configurar els paràmetres de xarxa de les interfícies. | F4 | 06-installacions |
| [x] | a245 | Apte | ISO-RA3 | Servidors GNU/Linux d’infraestructura: copiar les configuracions o imatges necessàries al servidor corresponent i justificar què es copia i què no. | F5 | 09-copies-contingencia |
| [x] | a246 | Apte | ISO-RA1 | En cada servidor GNU/Linux d’infraestructura: instal·lar i configurar el programari necessari per a la seua funcionalitat. De moment cap programari addicional, es veurà en tasques posteriors. | F4 | 06-installacions |
| [x] | a247 | Apte | ISO-RA1 | Windows 11: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F4 | 06-installacions |
| [x] | a248 | Apte | ISO-RA1 | Windows 11: configurar l’usuari o usuaris d’administració. | F4 | 06-installacions |
| [x] | a249 | Apte | ISO-RA1 | Windows 11: configurar els paràmetres de xarxa de les interfícies. | F4 | 06-installacions |
| [x] | a250 | Apte | ISO-RA3 | Windows 11: copiar les configuracions o imatges necessàries al servidor corresponent i justificar què es copia i què no. | F5 | 09-copies-contingencia |
| [x] | a252 | Apte | ISO-RA1 | GNU/Linux client: instal·lar el sistema previst i comprovar-ne la versió i el funcionament. | F4 | 06-installacions |
| [x] | a253 | Apte | ISO-RA1 | GNU/Linux client: configurar l’usuari o usuaris d’administració. | F4 | 06-installacions |
| [x] | a254 | Apte | ISO-RA1 | GNU/Linux client: configurar els paràmetres de xarxa de les interfícies. | F4 | 06-installacions |
| [x] | a255 | Apte | ISO-RA3 | GNU/Linux client: copiar les configuracions o imatges necessàries al servidor corresponent i justificar què es copia i què no. | F5 | 09-copies-contingencia |
| [x] | a258 | Apte | ISO-RA1 | Identificar possibles problemes dels diferents sistemes, detectar configuracions crítiques, temps de resposta davant una incidència d’instal·lació o arrencada. | F5 | 10-incidencies |
| [x] | a259 | Apte | ISO-RA1 | Preparar l’espai de còpies de seguretat en TrueNAS. Justificar què és còpia, com i on. | F4 | 06-installacions |
| [x] | a105 | Apte+ | ISO-RA3 | Automatitzar les còpies de configuracions o imatges. | F5 | 09-copies-contingencia |

## Tasca 6 · Emmagatzematge i recuperació

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [x] | a102 | Apte | ISO-RA3 | Crear i verificar almenys tres tipus de RAID. | F5 | 07-raid |
| [x] | a103 | Apte | ISO-RA3 | Explicar què aporta cada tipus de RAID. | F5 | 07-raid |
| [x] | a107 | Apte+ | ISO-RA3 | Investigar i justificar l’espill entre discos de dos equips diferents. | F5 (opcional, para el 10) | 07-raid |
| [x] | a108 | Apte+ | ISO-RA3 | Implementar l’espill entre dos discos de dos equips mitjançant la solució de replicació o emmagatzematge distribuït seleccionada. | F5 (opcional, para el 10) | 07-raid |
| [x] | a109 | Apte+ | ISO-RA3 | Verificar el funcionament i explicar un cas d’ús. | F5 (opcional, para el 10) | 07-raid |

## Tasca 7 · Rendiment i diagnòstic

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [x] | a22 | Apte | FDM-RA1 | Mesurar CPU, RAM, disc i xarxa durant les càrregues previstes. | F6 | 08-rendiment |
| [x] | a23 | Apte | FDM-RA1 · ISO-RA6 | Interpretar les mesures i identificar els recursos saturats. | F6 | 08-rendiment |
| [x] | a24 | Apte | FDM-RA1 | Determinar la capacitat del maquinari per executar les VM. | F6 | 08-rendiment |
| [x] | a119 | Apte | ISO-RA6 | Analitzar els recursos físics amb diferents càrregues de VM. | F6 | 08-rendiment |
| [x] | a120 | Apte | ISO-RA6 | Determinar quantes VM permeten treballar sense bloquejar l’equip. | F6 | 08-rendiment |
| [x] | a121 | Apte | ISO-RA6 | Lliurar l’informe de mesures i conclusions. | F6 | 08-rendiment |
| [x] | a123 | Apte+ | ISO-RA6 | Proposar i aplicar una primera optimització de les VM. | F6 | 08-rendiment |
| [x] | a124 | Apte+ | ISO-RA6 | Proposar i aplicar una segona optimització de les VM. | F6 | 08-rendiment |
| [x] | a125 | Apte+ | ISO-RA6 | Comparar les mesures de rendiment abans i després. | F6 | 08-rendiment |

## Tasca 8 · Prova final

| ☐ | ID | Nivel | RA | Actividad (texto del HTML) | Fase | Evidencia en |
|---|---|---|---|---|---|---|
| [ ] | a25 | Apte | FDM-RA1 | Diagnosticar i resoldre la incidència de maquinari del cas final. | Examen | Tasca 8 (examen) |
| [ ] | a26 | Apte | FDM-RA1 · ISO-RA1 · ISO-RA3 · ISO-RA6 | Justificar la solució i comprovar el resultat. | Examen | Tasca 8 (examen) |
| [ ] | a50 | Apte | FDM-RA4 | Identificar els equips empresarials i la seua funció en el cas final. | Examen | Tasca 8 (examen) |
| [ ] | a51 | Apte | FDM-RA4 | Inventariar les connexions i els ports del cas assignat. | Examen | Tasca 8 (examen) |
| [ ] | a52 | Apte | FDM-RA4 | Analitzar alimentació, ventilació i ordre del cablejat. | Examen | Tasca 8 (examen) |
| [ ] | a53 | Apte | FDM-RA4 | Aportar l’esquema i l’explicació individual de la solució. | Examen | Tasca 8 (examen) |
| [ ] | a80 | Apte | ISO-RA1 | Resoldre la incidència d’instal·lació, actualització o arrencada del cas final. | Examen | Tasca 8 (examen) |
| [ ] | a104 | Apte | ISO-RA3 | Recuperar la informació o el sistema previst en el cas final. | Examen | Tasca 8 (examen) |
| [ ] | a122 | Apte | ISO-RA6 | Diagnosticar el problema de rendiment del cas final. | Examen | Tasca 8 (examen) |
| [ ] | a30 | Apte+ | FDM-RA1 | Respondre el bloc del qüestionari teòric/pràctic corresponent a FDM RA1, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | Examen | Tasca 8 (examen) |
| [ ] | a57 | Apte+ | FDM-RA4 | Respondre el bloc del qüestionari teòric/pràctic corresponent a FDM RA4, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | Examen | Tasca 8 (examen) |
| [ ] | a84 | Apte+ | ISO-RA1 | Respondre el bloc del qüestionari teòric/pràctic corresponent a ISO RA1, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | Examen | Tasca 8 (examen) |
| [ ] | a110 | Apte+ | ISO-RA3 | Respondre el bloc del qüestionari teòric/pràctic corresponent a ISO RA3, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | Examen | Tasca 8 (examen) |
| [ ] | a126 | Apte+ | ISO-RA6 | Respondre el bloc del qüestionari teòric/pràctic corresponent a ISO RA6, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | Examen | Tasca 8 (examen) |
