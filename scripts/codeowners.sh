#!/bin/bash
# This will create 'CODEOWNERS' or overwrite it if it exists
meta git pull
meta git checkout -b fix-codeowners
meta exec "echo \"* @navikt/toi\" > CODEOWNERS"
meta git add CODEOWNERS
meta git commit -m "Legg til eller fikse CODEOWNERS"
meta git push -u origin fix-codeowners
meta echo "Opprettet branch 'fix-codeowners' og pushet endringene."
meta gh pr create --title "Opprett CODEOWNERS fil" --body "Oppretter en CODEOWNERS fil hvis det ikke finnes, eller oppdaterer den hvis den allerede eksisterer." --base main
meta echo "Pull request opprettet for å legge til eller fikse CODEOWNERS."
