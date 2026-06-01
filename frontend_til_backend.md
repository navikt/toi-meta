# Frontend → Backend kommunikasjon

```mermaid
graph LR
    %% Frontend-apper
    rekbis[rekrutteringsbistand-frontend]
    pres[presenterte-kandidater]
    rtb[rekrutteringstreff-bruker]
    vis[vis-stilling]
    finn[finn-stilling-inngang]

    %% Backend-apper (interne)
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
    pres-api[presenterte-kandidater-api]
    minside-api[rekrutteringstreff-minside-api]

    %% Eksterne tjenester (andre team)
    modia[modiacontextholder]
    notifikasjon[notifikasjon-bruker-api]
    pam-ontologi[pam-ontologi]
    pam-search[pam-search]
    pam-geografi[pam-geografi]
    ag-notifikasjon[arbeidsgiver-notifikasjon]

    %% finn-stilling-inngang (kun lenke, ingen API-kall)
    finn -. "lenke til /personbruker" .-> rekbis

    %% rekrutteringsbistand-frontend → backend
    rekbis -->|"/rekrutteringsbistandstilling/{id}<br>/standardsok<br>/overta-eierskap<br>/ny-stilling<br>/oppdater-stilling"| stilling-api
    rekbis -->|"/stilling/_search"| stillingssok
    rekbis -->|"/lookup-cv<br>/arena-kandidatnr<br>/navn<br>/kandidatsammendrag<br>/suggest/kontor<br>/suggest<br>/minebrukere"| kandidatsok
    rekbis -->|"/veileder/stilling/{id}/kandidatlisteinfo<br>/veileder/kandidater/{id}/listeoversikt<br>/veileder/kandidatlister<br>/veileder/stilling/{id}/kandidatnr<br>/veileder/stilling/{id}/kandidater"| kandidat-api
    rekbis -->|"/foresporsler/{stillingsId}<br>/statistikk"| foresporsel
    rekbis -->|"/statistikk"| statistikk
    rekbis -->|"/evaluering"| synlighet
    rekbis -->|"/{id}<br>/sok<br>/{id}/jobbsøkere<br>/{id}/arbeidsgivere<br>/{id}/innlegg<br>/{id}/eiere<br>/{id}/statushendelser<br>/{id}/allehendelser"| rektreff-api
    rekbis -->|"/api/bruker<br>/api/bruker/nyheter<br>/api/bruker/tilbakemeldinger"| bruker-api
    rekbis -->|"/varsler/stilling/{id}"| kandidatvarsel
    rekbis -->|"/api (context)"| modia
    rekbis -->|"/template"| ag-notifikasjon
    rekbis -->|"/stillingstittel<br>/samlede_kvalifikasjoner<br>/personlige_egenskaper"| pam-ontologi
    rekbis -->|"/underenhet"| pam-search
    rekbis -->|"/postdata/{postnr}<br>/typehead/lokasjoner"| pam-geografi

    %% presenterte-kandidater → backend
    pres -->|"/kandidatliste/{stillingsId}<br>/kandidatlister?virksomhetsnummer=<br>/organisasjoner<br>/hentsamtykke<br>/samtykke<br>/kandidat/{id}<br>/kandidat/{id}/vurdering<br>/kandidat/{id}/registrerviskontaktinfo"| pres-api
    pres -->|"/graphql"| notifikasjon

    %% rekrutteringstreff-bruker → backend
    rtb -->|"/rekrutteringstreff/{id}<br>/rekrutteringstreff/{id}/svar"| minside-api

    %% vis-stilling → backend
    vis -->|"/rekrutteringsbistand/ekstern/api/v1/stilling/{id}"| stilling-api

    %% Styling
    classDef frontend fill:#4a90d9,stroke:#2c5f8a,color:#fff
    classDef backend fill:#5bb55b,stroke:#3a7a3a,color:#fff
    classDef external fill:#f5a623,stroke:#c17d0e,color:#fff

    class rekbis,pres,rtb,vis,finn frontend
    class stilling-api,stillingssok,kandidatsok,kandidat-api,foresporsel,statistikk,synlighet,rektreff-api,bruker-api,kandidatvarsel,pres-api,minside-api backend
    class modia,notifikasjon,pam-ontologi,pam-search,pam-geografi,ag-notifikasjon external
```

## Legende

| Farge | Betydning |
|-------|-----------|
| 🔵 Blå | Frontend-apper (Next.js) |
| 🟢 Grønn | Backend-apper (eget team, Kotlin) |
| 🟠 Oransje | Eksterne tjenester (andre team) |

## Auth-mekanismer

| Frontend | Backend | Auth |
|----------|---------|------|
| rekrutteringsbistand-frontend | Alle interne backends | Azure AD OBO-token |
| presenterte-kandidater | presenterte-kandidater-api | TokenX (brukerkontext) |
| presenterte-kandidater | notifikasjon-bruker-api | TokenX (brukerkontext) |
| rekrutteringstreff-bruker | rekrutteringstreff-minside-api | TokenX (brukerkontext) |
| vis-stilling | rekrutteringsbistand-stilling-api | Azure client_credentials |
| finn-stilling-inngang | _(ingen backend-kall)_ | — |

## Notater

- **finn-stilling-inngang** er en mikrofrontend som kun lenker videre til rekrutteringsbistand-frontend
- **rekrutteringsbistand-frontend** er den sentrale saksbehandler-appen og kommuniserer med flest backends
- **vis-stilling** bruker client_credentials (maskin-til-maskin) fordi den viser stillinger til innbyggere uten brukerkontext
- **presenterte-kandidater** og **rekrutteringstreff-bruker** er innbygger-apper som bruker TokenX
