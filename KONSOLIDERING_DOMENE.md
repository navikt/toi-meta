# Konsolideringsanalyse: Domene og funksjonalitet

## Oversikt

Team Toi forvalter **18 repoer** som deployer totalt **~35 apper**. Denne analysen vurderer hvilke apper som kan slås sammen (eller deles opp) basert på domenetilhørighet og funksjonell kohesjon.

---

## Domenegrupper

### 1. Stilling (stillingsdata og publisering)

| App | Repo | Funksjon |
|-----|------|----------|
| rekrutteringsbistand-stilling-api | single | Administrerer stillingsdata, proxy mot PAM |
| rekrutteringsbistand-stillingssok-proxy | single | Proxy mot OpenSearch for stillingssøk |
| rekrutteringsbistand-stilling-kafkabro | single | Kopierer stillinger fra PAM-topic til eget topic |
| toi-stilling-indekser | mono (R&R) | Indekserer stillinger i OpenSearch |
| toi-publiser-dir-stillinger | mono (R&R) | Publiserer direktemeldte stillinger |
| toi-publisering-til-arbeidsplassen | mono (R&R) | Publisering til Arbeidsplassen |

**Vurdering:**
- **`rekrutteringsbistand-stillingssok-proxy`** er en ren proxy som kun leser fra OpenSearch. Den har ingen egen forretningslogikk utover tilgangskontroll — sterk kandidat for å slås inn i `rekrutteringsbistand-stilling-api`.
- **`rekrutteringsbistand-stilling-kafkabro`** bruker Aivia (standardimage) og har minimal kode — kunne potensielt erstattes av konfigurasjon, men har lav vedlikeholdskost alene.
- **`toi-publiser-dir-stillinger`** og **`toi-publisering-til-arbeidsplassen`** har overlappende navn og domene — bør vurderes sammenslått.
- **`toi-stilling-indekser`** er naturlig koblet til stilling-domenet men lever riktig som rapids-consumer.

**Anbefaling:** Slå sammen `stillingssok-proxy` → `stilling-api`. Vurder å slå sammen de to publiserings-appene i R&R.

---

### 2. Kandidat (CV, synlighet, søk)

| App | Repo | Funksjon |
|-----|------|----------|
| rekrutteringsbistand-kandidatsok-api | single | Søk i kandidater via OpenSearch |
| rekrutteringsbistand-kandidat-api | single (FSS) | Legacy kandidat-API (BFF-aktig rolle) |
| toi-kandidat-indekser | mono (R&R) | Indekserer kandidater i OpenSearch |
| toi-sammenstille-kandidat | mono (R&R) | Sammenstiller kandidatinfo fra rapids |
| toi-synlighetsmotor | mono (R&R) | Beregner synlighet for kandidater |
| toi-arbeidsmarked-cv | mono (R&R) | Leser CV-data til rapid |

**Vurdering:**
- **`rekrutteringsbistand-kandidat-api`** kjører i FSS (on-prem) og har legacy-preg. Den videresender kall til andre APIer. Funksjonaliteten bør gradvis migreres til `kandidatsok-api` (GCP) og `kandidatvarsel-api`.
- **`toi-synlighetsmotor`** har et REST-endepunkt som frontenden kaller direkte — den er en hybrid (rapids-consumer + API). Den ville funksjonelt passe sammen med `kandidatsok-api`, men har ulik deployfrekvens og ansvar.
- **`toi-sammenstille-kandidat`** og **`toi-kandidat-indekser`** er tett koblet (sammenstilling → indeksering). Sammen utgjør de «kandidat-pipeline». Sammenslåing kan forenkle feilsøking.

**Anbefaling:** Prioriter å fase ut `rekrutteringsbistand-kandidat-api` (FSS). Vurder å slå sammen `toi-sammenstille-kandidat` + `toi-kandidat-indekser` til én kandidat-pipeline-app.

---

### 3. Kandidatberikelse (datahøsting til rapid)

| App | Repo | Funksjon |
|-----|------|----------|
| toi-oppfolgingsinformasjon | mono (R&R) | Oppfølgingsinfo → rapid |
| toi-veileder | mono (R&R) | Veilederinfo → rapid |
| toi-geografi | mono (R&R) | Geografisk info → rapid |
| toi-hull-i-cv | mono (R&R) | Inaktive perioder → rapid |
| toi-kvp | mono (R&R) | KVP-info → rapid |
| toi-ontologitjeneste | mono (R&R) | Kompetanse-synonymer → rapid |
| toi-organisasjonsenhet | mono (R&R) | Organisasjonsenhet → rapid |
| toi-siste-14a-vedtak | mono (R&R) | 14a-vedtak → rapid |
| toi-siste-oppfolgingsperiode | mono (R&R) | Oppfølgingsperiode → rapid |
| toi-siste-oppfolgingsperiode-pond | mono (R&R) | Oppfølgingsperiode (pond) → rapid |
| toi-arbeidssoekerperiode | mono (R&R) | Arbeidssøkerperiode → rapid |
| toi-arbeidssoekeropplysninger | mono (R&R) | Arbeidssøkeropplysninger → rapid |
| toi-livshendelse | mono (R&R) | Diskresjonskoder fra PDL → rapid |
| toi-identmapper | mono (R&R) | Mapper identiteter |

**Vurdering:**
Disse 14 appene har nesten identisk arkitektur: les fra ekstern kilde/Kafka, berik, publiser på rapid. De fleste har ingen egen database, ingen inbound accessPolicy, og minimalt med kode.

**Sterke konsolideringskandidater:**
- **`toi-siste-oppfolgingsperiode`** og **`toi-siste-oppfolgingsperiode-pond`** — nesten identisk navn og funksjon.
- **`toi-oppfolgingsinformasjon`**, **`toi-kvp`**, **`toi-siste-14a-vedtak`** — alle henter data fra oppfølgingsdomenet.
- **`toi-arbeidssoekerperiode`** + **`toi-arbeidssoekeropplysninger`** — begge henter fra Arbeidssøkerregisteret (ASR).
- **`toi-geografi`** + **`toi-organisasjonsenhet`** — begge beriker med organisatorisk/geografisk metadata.
- **`toi-hull-i-cv`** + **`toi-ontologitjeneste`** — begge beriker CV-data.

**Anbefaling:** Konsolider i klynger: (1) oppfølging, (2) arbeidssøker, (3) CV-berikelse, (4) metadata. Kan redusere fra 14 til ~5 apper.

---

### 4. Rekrutteringstreff (ny funksjonalitet)

| App | Repo | Funksjon |
|-----|------|----------|
| rekrutteringstreff-api | mono | Veileder-API for rekrutteringstreff |
| rekrutteringstreff-minside-api | mono | Bruker-API (TokenX) for rekrutteringstreff |
| rekrutteringstreff-bruker | single | Next.js frontend for bruker |
| rekrutteringsbistand-aktivitetskort | mono | Aktivitetskort til Aktivitetsplanen |

**Vurdering:**
- Rekrutteringstreff er et nyere domene med ren arkitektur. `rekrutteringstreff-api` og `rekrutteringstreff-minside-api` deler database og repo — de er allerede logisk koblet.
- **`rekrutteringsbistand-aktivitetskort`** lever i samme repo men har et annet domene (integrerer mot Aktivitetsplanen). Den kunne leve som egen app, men delingsfri-gevinsten er begrenset.

**Anbefaling:** Behold som det er — god kohesjon allerede. Vurder om `aktivitetskort` hører hjemme i et annet repo på sikt.

---

### 5. Forespørsel og varsling (kommunikasjon med bruker/arbeidsgiver)

| App | Repo | Funksjon |
|-----|------|----------|
| foresporsel-om-deling-av-cv-api | single (FSS) | CV-deling-forespørsler til Aktivitetsplanen |
| rekrutteringsbistand-kandidatvarsel-api | single | Sender varsler til kandidater |
| toi-arbeidsgiver-notifikasjon | mono (R&R) | Notifikasjoner til Min Side Arbeidsgiver |

**Vurdering:**
- **`foresporsel-om-deling-av-cv-api`** kjører i FSS med Vault — bør migreres til GCP.
- Alle tre handler om «kommunikasjon utad» men mot ulike kanaler (Aktivitetsplan, bruker-varsler, arbeidsgiver-notifikasjoner). Sammenslåing gir ikke stor gevinst fordi integrasjonsflater er helt ulike.

**Anbefaling:** Migrer `foresporsel-om-deling-av-cv-api` til GCP. Behold separasjon — ulike integrasjoner rettferdiggjør egne apper.

---

### 6. Frontend (saksbehandler)

| App | Repo | Funksjon |
|-----|------|----------|
| rekrutteringsbistand-frontend | single | Hovedfrontend for saksbehandlere |
| finn-stilling-inngang | single | Inngang til «Finn stilling» fra ARBOP |

**Vurdering:**
- **`finn-stilling-inngang`** er en mikrofrontend/inngang som embeddes i Modia. Den har ingen auth, ingen backend — kun statisk HTML/JS. Veldig liten app.
- Kunne potensielt absorberes i `rekrutteringsbistand-frontend`, men lever godt som selvstendig deploy-enhet gitt ulik deployfrekvens.

**Anbefaling:** Lav prioritet. Kan forbli separat.

---

### 7. Frontend (bruker/arbeidsgiver)

| App | Repo | Funksjon |
|-----|------|----------|
| vis-stilling | single | Viser stillingsinformasjon til bruker |
| presenterte-kandidater | single | Arbeidsgiverflate for presenterte kandidater |
| rekrutteringstreff-bruker | single | Brukerflate for rekrutteringstreff |

**Vurdering:**
- Disse betjener helt ulike brukergrupper (bruker, arbeidsgiver, bruker). Ingen grunn til sammenslåing basert på domene alene.

**Anbefaling:** Behold separert.

---

### 8. Statistikk og driftsverktøy

| App | Repo | Funksjon |
|-----|------|----------|
| rekrutteringsbistand-statistikk-api | single (FSS) | Formidlingsstatistikk |
| rekrutteringsbistand-bruker-api | single | Nyheter i rekrutteringsbistand |
| toi-kafkamanager | single | Kafka-topic-administrasjon |
| toi-helseapp | mono (R&R) | Helsesjekk av rapids |

**Vurdering:**
- **`rekrutteringsbistand-statistikk-api`** er i FSS med Vault — bør migreres til GCP.
- **`rekrutteringsbistand-bruker-api`** håndterer kun nyheter/varsler for veiledere — svært liten forretningsverdi som egen tjeneste. Kan absorberes i `rekrutteringsbistand-frontend` som server-side funksjonalitet.

**Anbefaling:** Migrer `statistikk-api` til GCP. Vurder å flytte `bruker-api` inn i frontend.

---

## Prioritert konsolideringsliste

| # | Tiltak | Fra | Til | Begrunnelse | Kompleksitet |
|---|--------|-----|-----|-------------|-------------|
| 1 | Migrer til GCP | `foresporsel-om-deling-av-cv-api` (FSS) | GCP | Vault/webproxy-avhengighet, FSS-avvikling | Høy |
| 2 | Migrer til GCP | `rekrutteringsbistand-kandidat-api` (FSS) | GCP / fases ut | Legacy, mellomledd-rolle | Høy |
| 3 | Migrer til GCP | `rekrutteringsbistand-statistikk-api` (FSS) | GCP | Vault-avhengighet | Middels |
| 4 | Slå sammen | `stillingssok-proxy` → `stilling-api` | 1 app | Ren proxy uten logikk | Lav |
| 5 | Slå sammen | R&R oppfølgings-apper (3 stk) | 1 app | Samme datakilde, identisk mønster | Middels |
| 6 | Slå sammen | R&R arbeidssøker-apper (2 stk) | 1 app | Samme kilde (ASR) | Lav |
| 7 | Slå sammen | `sammenstille-kandidat` + `kandidat-indekser` | 1 app | Tett kobling, sekvensiell pipeline | Middels |
| 8 | Slå sammen | `toi-publiser-dir-stillinger` + `toi-publisering-til-arbeidsplassen` | 1 app | Overlappende domene | Lav |
| 9 | Absorber | `bruker-api` → `frontend` | SSR i frontend | Minimal logikk | Lav |
| 10 | Konsolider | Oppfølgingsperiode + pond | 1 app | Duplisert funksjon | Lav |

---

## Sammenligning: Domene-konsolidering vs. brukergruppe-konsolidering

### Fordeler med domene-konsolidering
- ✅ Høyere kohesjon innad i tjenestene — kode som endres sammen lever sammen
- ✅ Enklere feilsøking — hele flyten for et domene i ett repo
- ✅ Redusert nettverkstrafikk mellom tjenester
- ✅ Enklere å forstå systemet for nye utviklere

### Ulemper med domene-konsolidering
- ⚠️ Kan bety at én app trenger flere auth-mekanismer (Azure AD + TokenX)
- ⚠️ Større blast radius ved deploy
- ⚠️ Kan gi for store apper (kognitiv last)

### Når domene-konsolidering gir mest mening
- For **kandidatberikelse-appene** (R&R) er domene-konsolidering klart best — de har identisk arkitektur, ingen auth, og endres sjelden
- For **stilling-domenet** (proxy + API) er det også naturlig — de opererer på samme data
- For apper med **ulike brukergrupper** (veileder vs. bruker vs. arbeidsgiver) bør domene-konsolidering unngås — se `KONSOLIDERING_BRUKERGRUPPE.md`

---

## Oppsummering

De lavest-hengende fruktene er:
1. **Migrer FSS-appene til GCP** (3 apper) — dette er uavhengig av konsolideringsvalg
2. **Slå sammen R&R-berikelsesapper** etter datakilde — reduserer fra ~14 til ~5 apper
3. **Absorber `stillingssok-proxy` i `stilling-api`** — enkel, lav risiko

Totalt kan porteføljen reduseres fra **~35 til ~22 deploybare enheter** uten å miste funksjonalitet eller fleksibilitet.
