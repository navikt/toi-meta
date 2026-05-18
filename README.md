# toi-meta

Startpunkt (metarepo) for toi

## Komme i gang

### Oppsett av meta-repo

[meta](https://github.com/mateodelnorte/meta) brukes til å sette opp
repositories for alle repoene.

Enn så lenge må du sørge for å ha `npm` installert (`brew install node`).

```
npm install meta -g --no-save
```

Merk! meta foran vanlig clone-kommando:

```
meta git clone git@github.com:navikt/toi-meta.git
```

Nå kan git brukes som normalt for hvert repo.

For å legge til et nytt repo kan man skrive

```
meta project import repo-navn git@github.com:navikt/repo-navn
```

Se [meta](https://github.com/mateodelnorte/meta) for flere kommandoer.
