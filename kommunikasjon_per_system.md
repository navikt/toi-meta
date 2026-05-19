# Kommunikasjon per system

Samlet oversikt over all kommunikasjon (synkron og asynkron) per interne system. Dataene er kombinert fra:
- `frontend_til_backend.md` (frontend → backend)
- `backend_til_backend_synkron.md` (backend → backend HTTP)
- `backend_til_backend_asynkron.md` (backend → backend Kafka)

## Legende

| Symbol | Betydning |
|--------|-----------|
| **Heltrukket linje** (`-->`) | Synkront HTTP-kall |
| **Stiplet linje** (`-.->`) | Asynkron Kafka-kommunikasjon |
| 🔵 Blå | Frontend-apper |
| 🟢 Grønn | Interne backend-apper (eget team) |
| 🟠 Oransje | Eksterne tjenester (andre team) |
| 🟣 Lilla | Kafka topics |
| 🔲 Grå | Infrastruktur (OpenSearch) |

---

## rekrutteringsbistand-frontend

```mermaid
graph TB
    subgraph rekrutteringsbistand-frontend
        rekbis[rekrutteringsbistand-frontend]
    end

    %% Interne backends
    stilling-api[rekrutteringsbistand-stilling-api]
    stillingssok[rekrutteringsbistand-stillingssok-proxy]
    kandidatsok[rekrutteringsbistand-kandidatsok-api]
    kandidat-api[rekrutteringsbistand-kandidat-api]
    foresporsel[foresporsel-om-deling-av-cv-api]
    statistikk[rekrutteringsbistand-statistikk-api]
    synlighet[toi-synlighetsmotor]
    rektreff-api[rekrutteringstreff-api]
    bruker-api[rekrutteringsbistand-bruker-api]
    kandidatvarsel[rekrutteringsbistand-kandidatvarsel-api]

    %% Eksterne
    modia[modiacontextholder]
    ag-notifikasjon[arbeidsgiver-notifikasjon]
    pam-ontologi[pam-ontologi]
    pam-search[pam-search]
    pam-geografi[pam-geografi]

    %% Synkrone kall
    rekbis -->|"SYNC: /rekrutteringsbistandstilling/{id}<br>/standardsok /ny-stilling"| stilling-api
    rekbis -->|"SYNC: /stilling/_search"| stillingssok
    rekbis -->|"SYNC: /lookup-cv /arena-kandidatnr<br>/navn /kandidatsammendrag /suggest"| kandidatsok
    rekbis -->|"SYNC: /veileder/stilling/{id}/kandidater<br>/veileder/kandidatlister"| kandidat-api
    rekbis -->|"SYNC: /foresporsler/{stillingsId}<br>/statistikk"| foresporsel
    rekbis -->|"SYNC: /statistikk"| statistikk
    rekbis -->|"SYNC: /evaluering"| synlighet
    rekbis -->|"SYNC: /{id} /sok /{id}/jobbsøkere<br>/{id}/arbeidsgivere /{id}/innlegg"| rektreff-api
    rekbis -->|"SYNC: /api/bruker /api/bruker/nyheter"| bruker-api
    rekbis -->|"SYNC: /varsler/stilling/{id}"| kandidatvarsel
    rekbis -->|"SYNC: /api (context)"| modia
    rekbis -->|"SYNC: /template"| ag-notifikasjon
    rekbis -->|"SYNC: /stillingstittel<br>/samlede_kvalifikasjoner"| pam-ontologi
    rekbis -->|"SYNC: /underenhet"| pam-search
    rekbis -->|"SYNC: /postdata/{postnr}<br>/typehead/lokasjoner"| pam-geografi

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class rekbis frontend
    class stilling-api,stillingssok,kandidatsok,kandidat-api,foresporsel,statistikk,synlighet,rektreff-api,bruker-api,kandidatvarsel backend
    class modia,ag-notifikasjon,pam-ontologi,pam-search,pam-geografi external
```

---

## presenterte-kandidater

```mermaid
graph TB
    subgraph presenterte-kandidater
        pres[presenterte-kandidater]
    end

    pres-api[presenterte-kandidater-api]
    notifikasjon[notifikasjon-bruker-api]

    pres -->|"SYNC: /kandidatliste/{stillingsId}<br>/kandidatlister?virksomhetsnummer=<br>/organisasjoner /samtykke"| pres-api
    pres -->|"SYNC: /graphql"| notifikasjon

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class pres frontend
    class pres-api backend
    class notifikasjon external
```

---

## rekrutteringstreff-bruker

```mermaid
graph TB
    subgraph rekrutteringstreff-bruker
        rtb[rekrutteringstreff-bruker]
    end

    minside-api[rekrutteringstreff-minside-api]

    rtb -->|"SYNC: /rekrutteringstreff/{id}<br>/rekrutteringstreff/{id}/svar"| minside-api

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    class rtb frontend
    class minside-api backend
```

---

## vis-stilling

```mermaid
graph TB
    subgraph vis-stilling
        vis[vis-stilling]
    end

    stilling-api[rekrutteringsbistand-stilling-api]

    vis -->|"SYNC: /rekrutteringsbistand/ekstern/api/v1/stilling/{id}"| stilling-api

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    class vis frontend
    class stilling-api backend
```

---

## rekrutteringsbistand-stilling-api

```mermaid
graph TB
    subgraph rekrutteringsbistand-stilling-api
        stilling-api[rekrutteringsbistand-stilling-api]
    end

    %% Interne synkrone
    kandidat-api[rekrutteringsbistand-kandidat-api]
    stillingssok[rekrutteringsbistand-stillingssok-proxy]

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]
    vis[vis-stilling]
    kandidatvarsel[rekrutteringsbistand-kandidatvarsel-api]
    stilling-indekser[toi-stilling-indekser]

    %% Eksterne synkrone
    pam-ad-api[pam-ad-api]
    pam-geografi[pam-geografi]

    %% Topics
    rapid([toi.rapid-1])
    stilling-topic([toi.rekrutteringsbistand-stilling-1])

    %% Synkrone utgående
    stilling-api -->|"SYNC: GET /b2b/api/v1/ads/{id}"| pam-ad-api
    stilling-api -->|"SYNC: PUT/DELETE .../rest/veileder/stilling/{id}"| kandidat-api
    stilling-api -->|"SYNC: GET /stilling/_doc/{id}"| stillingssok
    stilling-api -->|"SYNC: GET /rest/postdata"| pam-geografi

    %% Synkrone innkommende
    rekbis -->|"SYNC: /rekrutteringsbistandstilling/{id}"| stilling-api
    vis -->|"SYNC: /ekstern/api/v1/stilling/{id}"| stilling-api
    kandidatvarsel -->|"SYNC: GET /ekstern/api/v1/stilling/{id}"| stilling-api
    stilling-indekser -->|"SYNC: POST /reindekser/stillinger<br>POST /indekser/stillingsinfo/bulk"| stilling-api

    %% Asynkrone
    stilling-api -.->|"ASYNC WRITE: indekserDirektemeldtStilling<br>reindekserDirektemeldtStilling<br>indekserStillingsinfo<br>publiserEllerAvpubliserTilArbeidsplassen"| rapid
    rapid -.->|"ASYNC READ: meldinger med stillingsId<br>som mangler stilling (StillingPopulator)"| stilling-api
    stilling-topic -.->|"ASYNC READ: kompakterte stillinger"| stilling-api

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class rekbis,vis frontend
    class stilling-api,kandidat-api,stillingssok,kandidatvarsel,stilling-indekser backend
    class pam-ad-api,pam-geografi external
    class rapid,stilling-topic topic
```

---

## rekrutteringsbistand-kandidat-api

```mermaid
graph TB
    subgraph rekrutteringsbistand-kandidat-api
        kandidat-api[rekrutteringsbistand-kandidat-api]
    end

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]
    stilling-api[rekrutteringsbistand-stilling-api]

    %% Topics
    rapid([toi.rapid-1])

    %% Synkrone innkommende
    rekbis -->|"SYNC: /veileder/stilling/{id}/kandidater<br>/veileder/kandidatlister"| kandidat-api
    stilling-api -->|"SYNC: PUT/DELETE .../rest/veileder/stilling/{id}"| kandidat-api

    %% Asynkrone
    kandidat-api -.->|"ASYNC WRITE: kandidat_v2.OpprettetKandidatliste<br>kandidat_v2.DelCvMedArbeidsgiver<br>kandidat_v2.RegistrertFåttJobben<br>kandidat_v2.LukketKandidatliste<br>+ 6 andre events"| rapid

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class rekbis frontend
    class kandidat-api,stilling-api backend
    class rapid topic
```

---

## foresporsel-om-deling-av-cv-api

```mermaid
graph TB
    subgraph foresporsel-om-deling-av-cv-api
        foresporsel-api[foresporsel-om-deling-av-cv-api]
    end

    %% Interne synkrone
    kandidatsok[rekrutteringsbistand-kandidatsok-api]
    stillingssok[rekrutteringsbistand-stillingssok-proxy]

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]

    %% Eksterne synkrone
    pam-personoppslag[pam-personoppslag]

    %% Topics
    rapid([toi.rapid-1])
    foresporsel-topic([pto.deling-av-stilling-fra-nav-forespurt-v2])
    svar-topic([pto.stilling-fra-nav-oppdatert-v2])
    statusoppdatering([pto.rekrutteringsbistand-statusoppdatering-v1])

    %% Eksterne async
    veilarbaktivitet[veilarbaktivitet<br>team-dab]

    %% Synkrone utgående
    foresporsel-api -->|"SYNC: POST /api/brukertilgang"| kandidatsok
    foresporsel-api -->|"SYNC: GET /stilling/_doc/{uuid}"| stillingssok
    foresporsel-api -->|"SYNC: GET /pam-personoppslag/.../oppslag/{ident}"| pam-personoppslag

    %% Synkrone innkommende
    rekbis -->|"SYNC: /foresporsler/{stillingsId}"| foresporsel-api

    %% Asynkrone
    rapid -.->|"ASYNC READ: kandidat_v2.DelCvMedArbeidsgiver<br>kandidat_v2.LukketKandidatliste<br>kandidat_v2.RegistrertFåttJobben"| foresporsel-api
    foresporsel-api -.->|"ASYNC WRITE: ForesporselOmDelingAvCv (Avro)"| foresporsel-topic
    foresporsel-api -.->|"ASYNC WRITE: CV_DELT / FATT_JOBBEN /<br>IKKE_FATT_JOBBEN"| statusoppdatering
    svar-topic -.->|"ASYNC READ: DelingAvCvRespons (Avro)"| foresporsel-api
    foresporsel-topic -.->|"konsumeres av"| veilarbaktivitet
    veilarbaktivitet -.->|"skriver svar"| svar-topic

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class rekbis frontend
    class foresporsel-api,kandidatsok,stillingssok backend
    class pam-personoppslag,veilarbaktivitet external
    class rapid,foresporsel-topic,svar-topic,statusoppdatering topic
```

---

## presenterte-kandidater-api

```mermaid
graph TB
    subgraph presenterte-kandidater-api
        presenterte-api[presenterte-kandidater-api]
    end

    %% Innkommende synkrone
    pres[presenterte-kandidater]

    %% Eksterne synkrone
    opensearch[(OpenSearch)]
    altinn[arbeidsgiver-altinn-tilganger]

    %% Topics
    rapid([toi.rapid-1])

    %% Synkrone utgående
    presenterte-api -->|"SYNC: POST /kandidater/_search<br>GET /kandidater/_count"| opensearch
    presenterte-api -->|"SYNC: POST (TokenX tilgangsforespørsel)"| altinn

    %% Synkrone innkommende
    pres -->|"SYNC: /kandidatliste/{stillingsId}<br>/organisasjoner /samtykke"| presenterte-api

    %% Asynkrone
    rapid -.->|"ASYNC READ: kandidat_v2.DelCvMedArbeidsgiver<br>kandidat_v2.OpprettetKandidatliste<br>kandidat_v2.LukketKandidatliste<br>kandidat_v2.SlettetStillingOgKandidatliste<br>kandidat_v2.SlettFraArbeidsgiversKandidatliste"| presenterte-api
    presenterte-api -.->|"ASYNC WRITE: notifikasjon.cv-delt<br>arbeidsgiversKandidatliste.VisningKontaktinfo"| rapid

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    classDef infra fill:#7f8c8d,stroke:#5d6d7e,color:#fff
    class pres frontend
    class presenterte-api backend
    class altinn external
    class opensearch infra
    class rapid topic
```

---

## rekrutteringstreff-api

```mermaid
graph TB
    subgraph rekrutteringstreff-api
        rektreff-api[rekrutteringstreff-api]
    end

    %% Interne synkrone
    kandidatsok[rekrutteringsbistand-kandidatsok-api]

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]
    minside-api[rekrutteringstreff-minside-api]

    %% Eksterne synkrone
    modia[modiacontextholder]
    openai[Azure OpenAI]

    %% Topics
    rapid([toi.rapid-1])

    %% Synkrone utgående
    rektreff-api -->|"SYNC: GET /api/context/v2/aktivenhet"| modia
    rektreff-api -->|"SYNC: POST /api/arena-kandidatnr"| kandidatsok
    rektreff-api -->|"SYNC: POST /chat/completions"| openai

    %% Synkrone innkommende
    rekbis -->|"SYNC: /{id} /sok /{id}/jobbsøkere<br>/{id}/arbeidsgivere"| rektreff-api
    minside-api -->|"SYNC: GET /api/rekrutteringstreff/{id}<br>GET /{id}/arbeidsgiver /{id}/innlegg<br>GET/POST /{id}/jobbsoker/borger"| rektreff-api

    %% Asynkrone
    rektreff-api -.->|"ASYNC WRITE: rekrutteringstreffinvitasjon<br>rekrutteringstreffoppdatering<br>rekrutteringstreffSvarOgStatus<br>behov synlighetRekrutteringstreff"| rapid
    rapid -.->|"ASYNC READ: synlighet.erSynlig<br>synlighetRekrutteringstreff (svar)<br>aktivitetskort-feil<br>minsideVarselSvar"| rektreff-api

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class rekbis frontend
    class rektreff-api,kandidatsok,minside-api backend
    class modia,openai external
    class rapid topic
```

---

## rekrutteringstreff-minside-api

```mermaid
graph TB
    subgraph rekrutteringstreff-minside-api
        minside-api[rekrutteringstreff-minside-api]
    end

    %% Innkommende synkrone
    rtb[rekrutteringstreff-bruker]

    %% Synkrone utgående
    rektreff-api[rekrutteringstreff-api]

    %% Synkrone
    rtb -->|"SYNC: /rekrutteringstreff/{id}<br>/rekrutteringstreff/{id}/svar"| minside-api
    minside-api -->|"SYNC: GET /api/rekrutteringstreff/{id}<br>GET /{id}/arbeidsgiver /{id}/innlegg<br>GET/POST /{id}/jobbsoker/borger"| rektreff-api

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    class rtb frontend
    class minside-api,rektreff-api backend
```

---

## rekrutteringsbistand-kandidatsok-api

```mermaid
graph TB
    subgraph rekrutteringsbistand-kandidatsok-api
        kandidatsok[rekrutteringsbistand-kandidatsok-api]
    end

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]
    foresporsel[foresporsel-om-deling-av-cv-api]
    kandidatvarsel[rekrutteringsbistand-kandidatvarsel-api]
    rektreff-api[rekrutteringstreff-api]

    %% Synkrone utgående (interne)
    livshendelse[toi-livshendelse]

    %% Eksterne synkrone
    pdl[PDL]
    modia[modiacontextholder]
    opensearch[(OpenSearch)]

    %% Synkrone utgående
    kandidatsok -->|"SYNC: POST (GraphQL hentPerson)"| pdl
    kandidatsok -->|"SYNC: POST /adressebeskyttelse"| livshendelse
    kandidatsok -->|"SYNC: GET /api/decorator"| modia
    kandidatsok -->|"SYNC: POST/GET (queries)"| opensearch

    %% Synkrone innkommende
    rekbis -->|"SYNC: /lookup-cv /arena-kandidatnr<br>/navn /kandidatsammendrag"| kandidatsok
    foresporsel -->|"SYNC: POST /api/brukertilgang"| kandidatsok
    kandidatvarsel -->|"SYNC: POST /api/brukertilgang"| kandidatsok
    rektreff-api -->|"SYNC: POST /api/arena-kandidatnr"| kandidatsok

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef infra fill:#7f8c8d,stroke:#5d6d7e,color:#fff
    class rekbis frontend
    class kandidatsok,foresporsel,kandidatvarsel,rektreff-api,livshendelse backend
    class pdl,modia external
    class opensearch infra
```

---

## rekrutteringsbistand-kandidatvarsel-api

```mermaid
graph TB
    subgraph rekrutteringsbistand-kandidatvarsel-api
        kandidatvarsel[rekrutteringsbistand-kandidatvarsel-api]
    end

    %% Interne synkrone
    stilling-api[rekrutteringsbistand-stilling-api]
    kandidatsok[rekrutteringsbistand-kandidatsok-api]

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]

    %% Topics
    rapid([toi.rapid-1])
    minside-bestilling([min-side.aapen-brukervarsel-v1])
    minside-hendelse([min-side.aapen-varsel-hendelse-v1])

    %% Eksterne
    minside[MinSide / tms]

    %% Synkrone utgående
    kandidatvarsel -->|"SYNC: GET /ekstern/api/v1/stilling/{id}"| stilling-api
    kandidatvarsel -->|"SYNC: POST /api/brukertilgang"| kandidatsok

    %% Synkrone innkommende
    rekbis -->|"SYNC: /varsler/stilling/{id}"| kandidatvarsel

    %% Asynkrone
    rapid -.->|"ASYNC READ: rekrutteringstreffinvitasjon<br>rekrutteringstreffoppdatering<br>rekrutteringstreffSvarOgStatus (avlyst)"| kandidatvarsel
    kandidatvarsel -.->|"ASYNC WRITE: varselbeskjed"| minside-bestilling
    minside-hendelse -.->|"ASYNC READ: varseloppdateringer"| kandidatvarsel
    kandidatvarsel -.->|"ASYNC WRITE: minsideVarselSvar"| rapid
    minside-bestilling -.->|"konsumeres av"| minside
    minside -.->|"skriver hendelser"| minside-hendelse

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class rekbis frontend
    class kandidatvarsel,stilling-api,kandidatsok backend
    class minside external
    class rapid,minside-bestilling,minside-hendelse topic
```

---

## rekrutteringsbistand-statistikk-api

```mermaid
graph TB
    subgraph rekrutteringsbistand-statistikk-api
        statistikk[rekrutteringsbistand-statistikk-api]
    end

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]

    %% Topics
    rapid([toi.rapid-1])
    kandidatutfall([toi.kandidatutfall])

    %% Eksterne
    datavarehus[Datavarehus<br>teamoppfolging / team-dialog]

    %% Synkrone innkommende
    rekbis -->|"SYNC: /statistikk"| statistikk

    %% Asynkrone
    rapid -.->|"ASYNC READ: kandidat_v2.OpprettetKandidatliste<br>kandidat_v2.DelCvMedArbeidsgiver<br>kandidat_v2.RegistrertDeltCv<br>kandidat_v2.RegistrertFåttJobben<br>+ 4 andre events"| statistikk
    statistikk -.->|"ASYNC WRITE: kandidatutfall (Avro)"| kandidatutfall
    kandidatutfall -.->|"konsumeres av"| datavarehus

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class rekbis frontend
    class statistikk backend
    class datavarehus external
    class rapid,kandidatutfall topic
```

---

## rekrutteringsbistand-stilling-kafkabro

```mermaid
graph TB
    subgraph rekrutteringsbistand-stilling-kafkabro
        kafkabro[rekrutteringsbistand-stilling-kafkabro<br>Aivia]
    end

    %% Topics
    stilling-ekstern([teampam.stilling-ekstern-1])
    stilling-topic([toi.rekrutteringsbistand-stilling-1])

    %% Eksterne
    pam-ad[pam-ad-api<br>teampam]

    %% Asynkrone
    pam-ad -.->|"ASYNC: publiserer stillinger"| stilling-ekstern
    stilling-ekstern -.->|"ASYNC READ: kilde-stillinger"| kafkabro
    kafkabro -.->|"ASYNC WRITE: kopierer stillinger"| stilling-topic

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class kafkabro backend
    class pam-ad external
    class stilling-ekstern,stilling-topic topic
```

---

## rekrutteringsbistand-stillingssok-proxy

```mermaid
graph TB
    subgraph rekrutteringsbistand-stillingssok-proxy
        stillingssok[rekrutteringsbistand-stillingssok-proxy]
    end

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]
    stilling-api[rekrutteringsbistand-stilling-api]
    foresporsel[foresporsel-om-deling-av-cv-api]

    %% Infrastruktur
    opensearch[(OpenSearch)]

    %% Synkrone utgående
    stillingssok -->|"SYNC: proxy til OpenSearch"| opensearch

    %% Synkrone innkommende
    rekbis -->|"SYNC: /stilling/_search"| stillingssok
    stilling-api -->|"SYNC: GET /stilling/_doc/{id}"| stillingssok
    foresporsel -->|"SYNC: GET /stilling/_doc/{uuid}"| stillingssok

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef infra fill:#7f8c8d,stroke:#5d6d7e,color:#fff
    class rekbis frontend
    class stillingssok,stilling-api,foresporsel backend
    class opensearch infra
```

---

## rekrutteringsbistand-bruker-api

```mermaid
graph TB
    subgraph rekrutteringsbistand-bruker-api
        bruker-api[rekrutteringsbistand-bruker-api]
    end

    %% Innkommende synkrone
    rekbis[rekrutteringsbistand-frontend]

    %% Synkrone innkommende
    rekbis -->|"SYNC: /api/bruker<br>/api/bruker/nyheter<br>/api/bruker/tilbakemeldinger"| bruker-api

    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    class rekbis frontend
    class bruker-api backend
```

---

## rekrutteringsbistand-aktivitetskort

```mermaid
graph TB
    subgraph rekrutteringsbistand-aktivitetskort
        aktivitetskort[rekrutteringsbistand-aktivitetskort]
    end

    %% Topics
    rapid([toi.rapid-1])
    dab-aktivitetskort([dab.aktivitetskort-v1.1])
    dab-feil([dab.aktivitetskort-feil-v1])

    %% Eksterne
    dab[DAB aktivitetsplan<br>team-dab]

    %% Asynkrone
    rapid -.->|"ASYNC READ: rekrutteringstreffinvitasjon<br>rekrutteringstreffSvarOgStatus<br>rekrutteringstreffoppdatering"| aktivitetskort
    aktivitetskort -.->|"ASYNC WRITE: aktivitetskort (JSON)"| dab-aktivitetskort
    dab-feil -.->|"ASYNC READ: feilmeldinger"| aktivitetskort
    dab-aktivitetskort -.->|"konsumeres av"| dab
    dab -.->|"skriver feilmeldinger"| dab-feil

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef topic fill:#9b59b6,stroke:#6c3483,color:#fff
    class aktivitetskort backend
    class dab external
    class rapid,dab-aktivitetskort,dab-feil topic
```

---

## toi-stilling-indekser

```mermaid
graph TB
    subgraph toi-stilling-indekser
        stilling-indekser[toi-stilling-indekser]
    end

    %% Synkrone utgående
    stilling-api[rekrutteringsbistand-stilling-api]
    opensearch[(OpenSearch)]

    stilling-indekser -->|"SYNC: POST /reindekser/stillinger<br>POST /indekser/stillingsinfo/bulk"| stilling-api
    stilling-indekser -->|"SYNC: indeksering"| opensearch

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef infra fill:#7f8c8d,stroke:#5d6d7e,color:#fff
    class stilling-indekser,stilling-api backend
    class opensearch infra
```

---

## toi-livshendelse

```mermaid
graph TB
    subgraph toi-livshendelse
        livshendelse[toi-livshendelse]
    end

    %% Innkommende synkrone
    kandidatsok[rekrutteringsbistand-kandidatsok-api]

    %% Eksterne synkrone
    pdl[PDL]

    livshendelse -->|"SYNC: POST (GraphQL hentIdenter + hentPerson)"| pdl
    kandidatsok -->|"SYNC: POST /adressebeskyttelse"| livshendelse

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class livshendelse,kandidatsok backend
    class pdl external
```

---

## toi-identmapper

```mermaid
graph TB
    subgraph toi-identmapper
        identmapper[toi-identmapper]
    end

    pdl[PDL]

    identmapper -->|"SYNC: POST (GraphQL hentIdenter)"| pdl

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class identmapper backend
    class pdl external
```

---

## toi-veileder

```mermaid
graph TB
    subgraph toi-veileder
        veileder[toi-veileder]
    end

    nom-api[nom-api]

    veileder -->|"SYNC: POST (GraphQL ressurser)"| nom-api

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class veileder backend
    class nom-api external
```

---

## toi-organisasjonsenhet

```mermaid
graph TB
    subgraph toi-organisasjonsenhet
        organisasjonsenhet[toi-organisasjonsenhet]
    end

    norg2[norg2]

    organisasjonsenhet -->|"SYNC: GET /enhet<br>GET /enhet?enhetsnummerListe={nr}"| norg2

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class organisasjonsenhet backend
    class norg2 external
```

---

## toi-ontologitjeneste

```mermaid
graph TB
    subgraph toi-ontologitjeneste
        ontologitjeneste[toi-ontologitjeneste]
    end

    pam-ontologi[pam-ontologi]

    ontologitjeneste -->|"SYNC: GET /kompetanse/?kompetansenavn={x}<br>GET /stilling/?stillingstittel={x}"| pam-ontologi

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class ontologitjeneste backend
    class pam-ontologi external
```

---

## toi-geografi

```mermaid
graph TB
    subgraph toi-geografi
        geografi[toi-geografi]
    end

    pam-geografi[pam-geografi]

    geografi -->|"SYNC: GET /rest/postdata<br>GET /rest/geografier"| pam-geografi

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class geografi backend
    class pam-geografi external
```

---

## toi-publisering-til-arbeidsplassen

```mermaid
graph TB
    subgraph toi-publisering-til-arbeidsplassen
        publisering[toi-publisering-til-arbeidsplassen]
    end

    arbeidsplassen[Arbeidsplassen stillingsimport]

    publisering -->|"SYNC: POST /stillingsimport/api/v1/transfers/{providerId}<br>DELETE /stillingsimport/api/v1/transfers/{providerId}/{ref}"| arbeidsplassen

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class publisering backend
    class arbeidsplassen external
```

---

## toi-arbeidsgiver-notifikasjon

```mermaid
graph TB
    subgraph toi-arbeidsgiver-notifikasjon
        ag-notifikasjon[toi-arbeidsgiver-notifikasjon]
    end

    notifikasjon-api[notifikasjon-bruker-api]

    ag-notifikasjon -->|"SYNC: POST (GraphQL mutations)"| notifikasjon-api

    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    class ag-notifikasjon backend
    class notifikasjon-api external
```

---

## Oppsummering

| System | Sync ut | Sync inn | Async ut | Async inn | Totalt |
|--------|---------|----------|----------|-----------|--------|
| rekrutteringsbistand-frontend | 15 | 0 | 0 | 0 | 15 |
| rekrutteringsbistand-stilling-api | 4 | 4 | 4 events | 2 topics | 14 |
| rekrutteringstreff-api | 3 | 2 | 4 events | 4 events | 13 |
| rekrutteringsbistand-kandidatvarsel-api | 2 | 1 | 2 topics | 2 topics | 7 |
| foresporsel-om-deling-av-cv-api | 3 | 1 | 2 topics | 2 topics | 8 |
| rekrutteringsbistand-kandidatsok-api | 4 | 4 | 0 | 0 | 8 |
| presenterte-kandidater-api | 2 | 1 | 2 events | 5 events | 10 |
| rekrutteringsbistand-statistikk-api | 0 | 1 | 1 topic | 9 events | 11 |
| rekrutteringsbistand-kandidat-api | 0 | 2 | 10 events | 0 | 12 |
| rekrutteringstreff-minside-api | 5 | 1 | 0 | 0 | 6 |
| rekrutteringsbistand-stillingssok-proxy | 1 | 3 | 0 | 0 | 4 |
| rekrutteringsbistand-aktivitetskort | 0 | 0 | 1 topic | 2 topics | 3 |
| rekrutteringsbistand-stilling-kafkabro | 0 | 0 | 1 topic | 1 topic | 2 |
| toi-stilling-indekser | 2 | 0 | 0 | 0 | 2 |
| presenterte-kandidater | 2 | 0 | 0 | 0 | 2 |
| rekrutteringstreff-bruker | 1 | 0 | 0 | 0 | 1 |
| vis-stilling | 1 | 0 | 0 | 0 | 1 |
| rekrutteringsbistand-bruker-api | 0 | 1 | 0 | 0 | 1 |
| toi-livshendelse | 1 | 1 | 0 | 0 | 2 |
| toi-identmapper | 1 | 0 | 0 | 0 | 1 |
| toi-veileder | 1 | 0 | 0 | 0 | 1 |
| toi-organisasjonsenhet | 1 | 0 | 0 | 0 | 1 |
| toi-ontologitjeneste | 1 | 0 | 0 | 0 | 1 |
| toi-geografi | 1 | 0 | 0 | 0 | 1 |
| toi-publisering-til-arbeidsplassen | 1 | 0 | 0 | 0 | 1 |
| toi-arbeidsgiver-notifikasjon | 1 | 0 | 0 | 0 | 1 |
