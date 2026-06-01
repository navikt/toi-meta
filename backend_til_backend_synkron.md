# Backend → Backend synkron kommunikasjon

```mermaid
graph LR
    %% Interne backend-apper
    stilling-api[rekrutteringsbistand-stilling-api]
    stillingssok-proxy[rekrutteringsbistand-stillingssok-proxy]
    kandidatsok-api[rekrutteringsbistand-kandidatsok-api]
    kandidat-api[rekrutteringsbistand-kandidat-api]
    kandidatvarsel-api[rekrutteringsbistand-kandidatvarsel-api]
    foresporsel-api[foresporsel-om-deling-av-cv-api]
    presenterte-api[presenterte-kandidater-api]
    rektreff-api[rekrutteringstreff-api]
    minside-api[rekrutteringstreff-minside-api]
    synlighetsmotor[toi-synlighetsmotor]
    livshendelse[toi-livshendelse]
    identmapper[toi-identmapper]
    veileder[toi-veileder]
    organisasjonsenhet[toi-organisasjonsenhet]
    ontologitjeneste[toi-ontologitjeneste]
    geografi[toi-geografi]
    stilling-indekser[toi-stilling-indekser]
    publisering-arbeidsplassen[toi-publisering-til-arbeidsplassen]
    arbeidsgiver-notifikasjon[toi-arbeidsgiver-notifikasjon]

    %% Eksterne tjenester (andre team)
    pam-ad-api[pam-ad-api<br>teampam]
    pam-geografi[pam-geografi<br>teampam]
    pam-ontologi[pam-ontologi<br>teampam]
    arbeidsplassen-import[arbeidsplassen<br>stillingsimport]
    opensearch[(OpenSearch)]
    pdl[PDL<br>person]
    nom-api[nom-api<br>NOM]
    norg2[norg2<br>org]
    modia[modiacontextholder<br>personoversikt]
    altinn-proxy[arbeidsgiver-altinn-tilganger<br>fager]
    notifikasjon-api[notifikasjon-bruker-api<br>fager]
    openai[Azure OpenAI]

    %% --- rekrutteringsbistand-stilling-api ---
    stilling-api -->|"GET /b2b/api/v1/ads/{id}"| pam-ad-api
    stilling-api -->|"PUT .../rest/veileder/stilling<br>DELETE .../rest/veileder/stilling/{id}"| kandidat-api
    stilling-api -->|"GET /stilling/_doc/{id}"| stillingssok-proxy
    stilling-api -->|"GET /rest/postdata"| pam-geografi

    %% --- foresporsel-om-deling-av-cv-api ---
    foresporsel-api -->|"POST /api/brukertilgang"| kandidatsok-api
    foresporsel-api -->|"GET /stilling/_doc/{uuid}"| stillingssok-proxy
    foresporsel-api -->|"GET /pam-personoppslag/personidenter/system/oppslag/{ident}"| pam-ad-api

    %% --- presenterte-kandidater-api ---
    presenterte-api -->|"POST /kandidater/_search<br>GET /kandidater/_count"| opensearch
    presenterte-api -->|"POST (TokenX-exchange → Altinn-tilganger)"| altinn-proxy

    %% --- rekrutteringstreff-api ---
    rektreff-api -->|"GET /api/context/v2/aktivenhet"| modia
    rektreff-api -->|"POST /api/arena-kandidatnr"| kandidatsok-api
    rektreff-api -->|"POST (chat/completions)"| openai

    %% --- rekrutteringstreff-minside-api ---
    minside-api -->|"GET /api/rekrutteringstreff/{id}<br>GET /api/rekrutteringstreff/{id}/arbeidsgiver<br>GET /api/rekrutteringstreff/{id}/innlegg"| rektreff-api
    minside-api -->|"GET /api/rekrutteringstreff/{id}/jobbsoker/borger<br>POST /api/rekrutteringstreff/{id}/jobbsoker/borger/svar-ja\|nei"| rektreff-api

    %% --- rekrutteringsbistand-kandidatsok-api ---
    kandidatsok-api -->|"POST (GraphQL hentPerson)"| pdl
    kandidatsok-api -->|"POST /adressebeskyttelse"| livshendelse
    kandidatsok-api -->|"GET /api/decorator"| modia
    kandidatsok-api -->|"POST/GET (OpenSearch queries)"| opensearch

    %% --- rekrutteringsbistand-kandidatvarsel-api ---
    kandidatvarsel-api -->|"GET /rekrutteringsbistand/ekstern/api/v1/stilling/{id}"| stilling-api
    kandidatvarsel-api -->|"POST /api/brukertilgang"| kandidatsok-api

    %% --- toi-stilling-indekser ---
    stilling-indekser -->|"POST /reindekser/stillinger"| stilling-api
    stilling-indekser -->|"POST /indekser/stillingsinfo/bulk"| stilling-api
    stilling-indekser -->|"(indeksering)"| opensearch

    %% --- toi-livshendelse ---
    livshendelse -->|"POST (GraphQL hentIdenter + hentPerson)"| pdl

    %% --- toi-identmapper ---
    identmapper -->|"POST (GraphQL hentIdenter)"| pdl

    %% --- toi-veileder ---
    veileder -->|"POST (GraphQL ressurser)"| nom-api

    %% --- toi-organisasjonsenhet ---
    organisasjonsenhet -->|"GET /enhet<br>GET /enhet?enhetsnummerListe={nr}"| norg2

    %% --- toi-ontologitjeneste ---
    ontologitjeneste -->|"GET /kompetanse/?kompetansenavn={x}<br>GET /stilling/?stillingstittel={x}"| pam-ontologi

    %% --- toi-geografi ---
    geografi -->|"GET /rest/postdata<br>GET /rest/geografier"| pam-geografi

    %% --- toi-publisering-til-arbeidsplassen ---
    publisering-arbeidsplassen -->|"POST /stillingsimport/api/v1/transfers/{providerId}<br>DELETE /stillingsimport/api/v1/transfers/{providerId}/{ref}"| arbeidsplassen-import

    %% --- toi-arbeidsgiver-notifikasjon ---
    arbeidsgiver-notifikasjon -->|"POST (GraphQL mutations)"| notifikasjon-api

    %% Styling
    classDef internal fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff
    classDef infra fill:#9b59b6,stroke:#6c3483,color:#fff

    class stilling-api,stillingssok-proxy,kandidatsok-api,kandidat-api,kandidatvarsel-api,foresporsel-api,presenterte-api,rektreff-api,minside-api,synlighetsmotor,livshendelse,identmapper,veileder,organisasjonsenhet,ontologitjeneste,geografi,stilling-indekser,publisering-arbeidsplassen,arbeidsgiver-notifikasjon internal
    class pam-ad-api,pam-geografi,pam-ontologi,arbeidsplassen-import,pdl,nom-api,norg2,modia,altinn-proxy,notifikasjon-api,openai external
    class opensearch infra
```

## Legende

| Farge | Betydning |
|-------|-----------|
| 🟢 Grønn | Interne backend-apper (eget team) |
| 🟠 Oransje | Eksterne tjenester (andre team / Nav-felles) |
| 🟣 Lilla | Infrastruktur (OpenSearch) |

## Oversikt per app

### rekrutteringsbistand-stilling-api
| Kaller | URL | Auth |
|--------|-----|------|
| pam-ad-api | `GET /b2b/api/v1/ads/{id}` | Azure client_credentials |
| rekrutteringsbistand-kandidat-api | `PUT/DELETE .../rest/veileder/stilling/{id}` | Azure OBO |
| rekrutteringsbistand-stillingssok-proxy | `GET /stilling/_doc/{id}` | Azure OBO / system |
| pam-geografi | `GET /rest/postdata` | Ingen (cluster-intern) |

### foresporsel-om-deling-av-cv-api
| Kaller | URL | Auth |
|--------|-----|------|
| rekrutteringsbistand-kandidatsok-api | `POST /api/brukertilgang` | Azure OBO |
| rekrutteringsbistand-stillingssok-proxy | `GET /stilling/_doc/{uuid}` | Azure client_credentials |
| pam-personoppslag (via pam-ad-api) | `GET /pam-personoppslag/personidenter/system/oppslag/{ident}` | Azure client_credentials |

### presenterte-kandidater-api
| Kaller | URL | Auth |
|--------|-----|------|
| OpenSearch | `POST /kandidater/_search`, `GET /kandidater/_count` | Basic auth |
| arbeidsgiver-altinn-tilganger | `POST /` (tilgangsforespørsel) | TokenX |

### rekrutteringstreff-api
| Kaller | URL | Auth |
|--------|-----|------|
| modiacontextholder | `GET /api/context/v2/aktivenhet` | Azure OBO |
| rekrutteringsbistand-kandidatsok-api | `POST /api/arena-kandidatnr` | Azure OBO |
| Azure OpenAI | `POST /chat/completions` | API-nøkkel |

### rekrutteringstreff-minside-api
| Kaller | URL | Auth |
|--------|-----|------|
| rekrutteringstreff-api | `GET /api/rekrutteringstreff/{id}` | TokenX |
| rekrutteringstreff-api | `GET /api/rekrutteringstreff/{id}/arbeidsgiver` | TokenX |
| rekrutteringstreff-api | `GET /api/rekrutteringstreff/{id}/innlegg` | TokenX |
| rekrutteringstreff-api | `GET /api/rekrutteringstreff/{id}/jobbsoker/borger` | TokenX |
| rekrutteringstreff-api | `POST /api/rekrutteringstreff/{id}/jobbsoker/borger/svar-ja\|nei` | TokenX |

### rekrutteringsbistand-kandidatsok-api
| Kaller | URL | Auth |
|--------|-----|------|
| PDL | `POST (GraphQL)` | Azure OBO |
| toi-livshendelse | `POST /adressebeskyttelse` | Azure OBO |
| modiacontextholder | `GET /api/decorator` | Azure OBO |
| OpenSearch | diverse queries | Basic auth |

### rekrutteringsbistand-kandidatvarsel-api
| Kaller | URL | Auth |
|--------|-----|------|
| rekrutteringsbistand-stilling-api | `GET /rekrutteringsbistand/ekstern/api/v1/stilling/{id}` | Azure client_credentials |
| rekrutteringsbistand-kandidatsok-api | `POST /api/brukertilgang` | Azure OBO |

### toi-stilling-indekser
| Kaller | URL | Auth |
|--------|-----|------|
| rekrutteringsbistand-stilling-api | `POST /reindekser/stillinger` | Azure client_credentials |
| rekrutteringsbistand-stilling-api | `POST /indekser/stillingsinfo/bulk` | Azure client_credentials |
| OpenSearch | indeksering | Basic auth |

### toi-livshendelse
| Kaller | URL | Auth |
|--------|-----|------|
| PDL | `POST (GraphQL hentIdenter + hentPerson)` | Azure client_credentials |

### toi-identmapper
| Kaller | URL | Auth |
|--------|-----|------|
| PDL | `POST (GraphQL hentIdenter)` | Azure client_credentials |

### toi-veileder
| Kaller | URL | Auth |
|--------|-----|------|
| nom-api | `POST (GraphQL ressurser)` | Azure client_credentials |

### toi-organisasjonsenhet
| Kaller | URL | Auth |
|--------|-----|------|
| norg2 | `GET /enhet`, `GET /enhet?enhetsnummerListe={nr}` | Ingen |

### toi-ontologitjeneste
| Kaller | URL | Auth |
|--------|-----|------|
| pam-ontologi | `GET /kompetanse/?kompetansenavn={x}`, `GET /stilling/?stillingstittel={x}` | Ingen |

### toi-geografi
| Kaller | URL | Auth |
|--------|-----|------|
| pam-geografi | `GET /rest/postdata`, `GET /rest/geografier` | Ingen |

### toi-publisering-til-arbeidsplassen
| Kaller | URL | Auth |
|--------|-----|------|
| Arbeidsplassen stillingsimport | `POST /stillingsimport/api/v1/transfers/{providerId}` | Bearer token |
| Arbeidsplassen stillingsimport | `DELETE /stillingsimport/api/v1/transfers/{providerId}/{ref}` | Bearer token |

### toi-arbeidsgiver-notifikasjon
| Kaller | URL | Auth |
|--------|-----|------|
| notifikasjon-bruker-api | `POST (GraphQL mutations)` | Azure client_credentials |

## Apper uten utgående synkrone kall

Følgende backend-apper gjør **kun** asynkron kommunikasjon (Kafka) og har ingen utgående HTTP-kall til andre backends:

- `rekrutteringsbistand-bruker-api`
- `rekrutteringsbistand-statistikk-api`
- `rekrutteringsbistand-stilling-kafkabro`
- `toi-kafkamanager`
- `toi-arbeidsmarked-cv`
- `toi-arbeidssoekeropplysninger`
- `toi-arbeidssoekerperiode`
- `toi-hull-i-cv`
- `toi-kvp`
- `toi-oppfolgingsinformasjon`
- `toi-sammenstille-kandidat`
- `toi-siste-14a-vedtak`
- `toi-siste-oppfolgingsperiode`
- `toi-siste-oppfolgingsperiode-pond`
- `toi-synlighetsmotor`
- `toi-helseapp`
- `toi-publiser-dir-stillinger`
- `rekrutteringsbistand-aktivitetskort`
