# Konsolideringsanalyse: Brukergrupper og auth-tokens

## Oversikt

Denne analysen vurderer konsolidering basert på **hvem som kaller tjenestene** og hvilke auth-mekanismer som brukes. I Nav/Nais bestemmer auth-tokenet mye av arkitekturen — å blande brukergrupper i én app gir kompleksitet i tilgangsstyring.

---

## Auth-mekanismer i bruk

| Mekanisme | Brukergruppe | Apper |
|-----------|-------------|-------|
| Azure AD (sidecar) | Nav-veileder via nettleser | rekrutteringsbistand-frontend |
| Azure AD (server-to-server) | Nav-interne tjenester | De fleste backend-APIer |
| ID-porten + Wonderwall | Innbygger/arbeidssøker | presenterte-kandidater, rekrutteringstreff-bruker |
| TokenX | Tjeneste-til-tjeneste med brukerkontext | presenterte-kandidater-api, rekrutteringstreff-minside-api |
| Ingen auth | Intern rapids/kafka | Alle R&R-berikelsesapper |
| Ingen auth (statisk) | Innbygger | finn-stilling-inngang |

---

## Brukergrupper

### Gruppe A: Nav-veileder (Azure AD)

Veiledere i Modia/Rekrutteringsbistand som jobber med kandidatmatching og stillingsadministrasjon.

| App | Type | Auth-detaljer |
|-----|------|---------------|
| **rekrutteringsbistand-frontend** | Frontend | Azure AD sidecar, AD-grupper (arb.giver/jobbsøker/utvikler) |
| **rekrutteringsbistand-stilling-api** | API | Azure AD, NAVident, AD-grupper |
| **rekrutteringsbistand-kandidatsok-api** | API | Azure AD, NAVident, AD-grupper |
| **rekrutteringsbistand-kandidatvarsel-api** | API | Azure AD, NAVident, AD-grupper |
| **rekrutteringsbistand-stillingssok-proxy** | Proxy | Azure AD, AD-grupper |
| **rekrutteringsbistand-bruker-api** | API | Azure AD, AD-grupper |
| **rekrutteringsbistand-kandidat-api** | API (FSS) | Azure AD, NAVident, AD-grupper |
| **rekrutteringsbistand-statistikk-api** | API (FSS) | Azure AD, AD-grupper |
| **foresporsel-om-deling-av-cv-api** | API (FSS) | Azure AD + TokenX, AD-grupper |
| **rekrutteringstreff-api** | API | Azure AD + TokenX, NAVident, AD-grupper |
| **toi-synlighetsmotor** | API+Consumer | Azure AD, AD-grupper (inbound fra frontend) |
| **toi-arbeidsgiver-notifikasjon** | Consumer | Azure AD (for outbound-kall) |
| **finn-stilling-inngang** | Frontend | Ingen egen auth (embeddet i Modia) |

**Observasjon:** Alle veileder-apper bruker samme sett med AD-grupper:
- Arbeidsgiverrettet
- Jobbsøkerrettet  
- Utvikler
- (Noen: Modia generell tilgang)

---

### Gruppe B: Arbeidsgiver (ID-porten + TokenX)

Arbeidsgivere som ser kandidater presentert av Nav.

| App | Type | Auth-detaljer |
|-----|------|---------------|
| **presenterte-kandidater** | Frontend | ID-porten + Wonderwall (Level4) |
| **presenterte-kandidater-api** | API | TokenX + Azure AD (dual), Altinn-roller |

**Observasjon:** Presenterte-kandidater-api har **dual auth** — den aksepterer både TokenX (fra arbeidsgiver-frontend) og Azure AD (fra veileder). Dette er en naturlig splittlinje.

---

### Gruppe C: Innbygger/arbeidssøker (ID-porten + TokenX)

Brukere som ser stillinger og rekrutteringstreff.

| App | Type | Auth-detaljer |
|-----|------|---------------|
| **rekrutteringstreff-bruker** | Frontend | ID-porten + Wonderwall (Level3) |
| **rekrutteringstreff-minside-api** | API | TokenX |
| **vis-stilling** | Frontend | Ingen bruker-auth (Azure AD kun for outbound-kall til stilling-api) |

---

### Gruppe D: Maskin-til-maskin (ingen brukerkontext)

Apper som prosesserer data uten brukerinteraksjon.

| App | Type | Auth-detaljer |
|-----|------|---------------|
| **toi-sammenstille-kandidat** | Consumer | Ingen inbound auth |
| **toi-kandidat-indekser** | Consumer | Ingen inbound auth |
| **toi-stilling-indekser** | Consumer | Azure AD (for inbound fra stilling-api) |
| **toi-arbeidsmarked-cv** | Consumer | Ingen auth |
| **toi-oppfolgingsinformasjon** | Consumer | Ingen auth |
| **toi-veileder** | Consumer | Azure AD (outbound) |
| **toi-livshendelse** | Consumer | Azure AD (outbound til PDL) |
| **toi-geografi** | Consumer | Ingen auth |
| **toi-hull-i-cv** | Consumer | Ingen auth |
| **toi-kvp** | Consumer | Ingen auth |
| **toi-ontologitjeneste** | Consumer | Ingen auth |
| **toi-organisasjonsenhet** | Consumer | Ingen auth |
| **toi-siste-14a-vedtak** | Consumer | Ingen auth |
| **toi-siste-oppfolgingsperiode** | Consumer | Ingen auth |
| **toi-siste-oppfolgingsperiode-pond** | Consumer | Ingen auth |
| **toi-arbeidssoekerperiode** | Consumer | Ingen auth |
| **toi-arbeidssoekeropplysninger** | Consumer | Ingen auth |
| **toi-publiser-dir-stillinger** | Consumer | Ingen auth |
| **toi-publisering-til-arbeidsplassen** | Consumer | Ingen auth |
| **toi-identmapper** | Consumer | Azure AD (outbound) |
| **rekrutteringsbistand-stilling-kafkabro** | Consumer | Ingen auth |
| **rekrutteringsbistand-aktivitetskort** | Consumer | Ingen auth |
| **toi-helseapp** | Driftsverktøy | Ingen auth |
| **toi-kafkamanager** | Driftsverktøy | Ikke spesifisert |

---

## Konsolideringsmuligheter basert på brukergruppe

### Mulighet 1: Konsolider veileder-APIer (Gruppe A)

**Kandidater for sammenslåing:**

```
rekrutteringsbistand-stilling-api
  + rekrutteringsbistand-stillingssok-proxy   ← Samme AD-grupper, stilling-domene
  + rekrutteringsbistand-bruker-api           ← Minimal logikk, samme AD-grupper
```

**Fordeler:**
- Alle bruker identisk Azure AD-oppsett med samme AD-grupper
- Reduserer antall token-valideringer og nettverkshop
- Frontend trenger færre outbound-regler

**Risiko:**
- Større app = større blast radius
- Ulikt teknisk stack (stilling-api er Spring Boot, stillingssok-proxy er Ktor)

**Vurdering:** ⭐⭐⭐ God kandidat, spesielt `stillingssok-proxy` → `stilling-api`

---

### Mulighet 2: Konsolider arbeidsgiver-APIer (Gruppe B)

```
presenterte-kandidater-api  (allerede i produksjon)
```

**Vurdering:** Det er kun én app her. Ingen konsolidering nødvendig. Men merk at `presenterte-kandidater-api` har **dual auth** — den kunne potensielt splittes i to:
- Én ren TokenX-app for arbeidsgiver (via `presenterte-kandidater`)
- Én Azure AD-app for veileder (via `rekrutteringsbistand-frontend` / `min-side-arbeidsgiver`)

Men dette ville *øke* antall apper. Dual auth er akseptabelt her.

---

### Mulighet 3: Konsolider innbygger-APIer (Gruppe C)

```
rekrutteringstreff-minside-api
  + vis-stilling (?)
```

**Vurdering:** ⭐ Lav verdi. `vis-stilling` har ingen bruker-auth (henter data via Azure AD server-to-server), mens `rekrutteringstreff-minside-api` bruker TokenX. Ulike auth-flows = dårlig kandidat for sammenslåing.

---

### Mulighet 4: Konsolider auth-frie consumers (Gruppe D)

```
Klynge 1 — «Oppfølging»:
  toi-oppfolgingsinformasjon + toi-kvp + toi-siste-14a-vedtak 
  + toi-siste-oppfolgingsperiode + toi-siste-oppfolgingsperiode-pond

Klynge 2 — «Arbeidssøker»:
  toi-arbeidssoekerperiode + toi-arbeidssoekeropplysninger

Klynge 3 — «CV-berikelse»:
  toi-hull-i-cv + toi-ontologitjeneste + toi-geografi

Klynge 4 — «Kandidat-pipeline»:
  toi-sammenstille-kandidat + toi-kandidat-indekser

Klynge 5 — «Stilling-pipeline»:
  toi-stilling-indekser + toi-publiser-dir-stillinger 
  + toi-publisering-til-arbeidsplassen + rekrutteringsbistand-stilling-kafkabro
```

**Fordeler:**
- Ingen auth-konflikter — alle er Kafka-consumers uten inbound-regler
- Identisk arkitekturmønster (les fra topic, skriv til rapid)
- Dramatisk reduksjon i antall pods og CI/CD-pipelines
- Enklere å få oversikt over hele berikelsesflyvten

**Risiko:**
- Større app = én consumer-feil kan ta ned hele klyngen
- Ulik deployfrekvens (noen endres sjelden)
- Consumer group-håndtering kan bli mer kompleks

**Mitigering:**
- Circuit breaker per dataflyt
- Feature flags for å disable enkelt-consumers
- Shared health endpoint som rapporterer per consumer

**Vurdering:** ⭐⭐⭐⭐⭐ Beste kandidat for brukergruppe-basert konsolidering. Auth-frie consumers har ingen grunn til å leve som separate apper utover historikk.

---

### Mulighet 5: Hybrid-apper med dual auth

Noen apper har allerede (eller trenger) støtte for flere auth-mekanismer:

| App | Auth 1 | Auth 2 | Grunn |
|-----|--------|--------|-------|
| presenterte-kandidater-api | TokenX (arbeidsgiver) | Azure AD (veileder) | To klientgrupper |
| rekrutteringstreff-api | Azure AD (veileder) | TokenX (via minside-api) | Indirekte brukerkontext |
| foresporsel-om-deling-av-cv-api | Azure AD (veileder) | TokenX (bruker-svar) | Toveis-flyt |

**Vurdering:** Disse bør **ikke** konsolideres ytterligere — de har allerede optimal separasjon. Dual auth er akseptabelt når flyten krever det.

---

## Prioritert konsolideringsliste (brukergruppe-perspektiv)

| # | Tiltak | Brukergruppe | Fra | Til | Kompleksitet |
|---|--------|-------------|-----|-----|-------------|
| 1 | Konsolider R&R-consumers | Maskin (ingen auth) | ~14 apper | ~5 klynger | Middels |
| 2 | Absorber stillingssok-proxy | Veileder (Azure AD) | 2 apper | 1 app | Lav |
| 3 | Absorber bruker-api i frontend | Veileder (Azure AD) | 2 apper | 1 app | Lav |
| 4 | Migrer FSS-apper til GCP | Veileder (Azure AD) | 3 FSS-apper | 3 GCP-apper | Høy |
| 5 | Splitt presenterte-kandidater-api (valgfritt) | Arbeidsgiver + Veileder | 1 app | 2 apper | Middels |

---

## Sammenligning: Brukergruppe-konsolidering vs. domene-konsolidering

### Fordeler med brukergruppe-konsolidering
- ✅ Enklere auth-håndtering — hver app har én autentiseringsmekanisme
- ✅ Klarere sikkerhetsgrenser — tilgangskontroll per app, ikke per endepunkt
- ✅ Bedre for compliance — audit trail per brukergruppe
- ✅ Naturlig separasjon av accessPolicy (inbound/outbound)

### Ulemper med brukergruppe-konsolidering
- ⚠️ Kan splitte domenelogikk over flere apper (f.eks. stilling-logikk i både veileder-app og bruker-app)
- ⚠️ Kan føre til duplisering av forretningsregler
- ⚠️ Krever mer inter-service-kommunikasjon for delte operasjoner

### Når brukergruppe-konsolidering gir mest mening
- For **Gruppe D (auth-frie consumers)** er dette den klart beste tilnærmingen — de har ingen brukerkontext og kan trygt samles
- For apper med **tydelig enkelt-brukergruppe** (f.eks. kun veileder) fungerer det godt å samle per brukergruppe
- Unngå sammenslåing av apper med **ulik brukergruppe** (f.eks. vis-stilling + rekrutteringsbistand-frontend)

---

## Anbefalt tilnærming: Kombinert strategi

De to perspektivene peker i **samme retning** for de viktigste tiltakene:

| Tiltak | Domene-perspektiv | Brukergruppe-perspektiv | Konklusjon |
|--------|------------------|------------------------|------------|
| Konsolider R&R-consumers | ✅ Samme domene-klynger | ✅ Alle auth-frie | **Gjør dette først** |
| `stillingssok-proxy` → `stilling-api` | ✅ Samme domene | ✅ Samme auth | **Gjør dette** |
| `bruker-api` → frontend | ✅ Minimal forretningslogikk | ✅ Samme auth | **Gjør dette** |
| Migrer FSS-apper | ✅ Uavhengig | ✅ Uavhengig | **Gjør dette (uavhengig)** |
| Splitt `presenterte-kandidater-api` | ❌ Splitter domene | ✅ Renere auth | **Avvent** — dual auth er ok |

### Der perspektivene er i konflikt:
- **`toi-synlighetsmotor`**: Domene sier «slå sammen med kandidatsok-api» (samme domene). Brukergruppe sier «behold separat» (den er consumer + API hybrid). **Anbefaling: Behold separat** — hybridrollen gjør den unik.
- **`toi-stilling-indekser` + `stilling-kafkabro`**: Domene sier «slå sammen med stilling-API» (samme domene). Brukergruppe sier «slå sammen med andre consumers» (maskin-til-maskin). **Anbefaling: Følg domene** — indekseringslogikk er tett knyttet til stilling-API.

---

## Oppsummering

**Brukergruppe-konsolidering er mest verdifull for Gruppe D (auth-frie consumers)** — her er det ingen auth-konflikter og stor operasjonell gevinst.

**Domene-konsolidering er mest verdifull for stilling- og kandidat-APIene** — her gir funksjonell kohesjon mer mening enn token-likhet.

**Begge perspektiver er enige** om at FSS-migrering, proxy-absorbasjon, og R&R-konsolidering bør prioriteres. Start der.
