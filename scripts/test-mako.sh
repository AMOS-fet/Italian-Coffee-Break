#!/bin/bash

# 1. IMPOSTAZIONI FISSE (Basate sui tuoi log precedenti)
DOTFILES="$HOME/dotfiles"
TEMPLATE="$DOTFILES/mako/.config/mako/dark"
TARGET="$HOME/.config/mako/config"
TEST_COLOR="#FF00FF" # Un Fucsia evidente per il test

echo "==================================================="
echo "🔍 MAKO DEBUGGER - CSI (Crime Scene Investigation)"
echo "==================================================="

# 2. ANALISI DEL TEMPLATE
echo -e "\n1. CONTROLLO FILE TEMPLATE:"
if [ -f "$TEMPLATE" ]; then
    echo "   ✅ File trovato: $TEMPLATE"
    
    # cat -A mostra TUTTI i caratteri, inclusi tab (^I) e fine riga ($)
    echo "   🔎 Contenuto esatto della riga border-color (con caratteri invisibili):"
    grep "border-color" "$TEMPLATE" | cat -A
    
    # Controlliamo se grep lo trova normalmente
    if grep -q "^border-color=" "$TEMPLATE"; then
        echo "   ✅ Grep standard trova 'border-color=' a inizio riga."
    elif grep -q "border-color=" "$TEMPLATE"; then
        echo "   ⚠️  Grep trova 'border-color=' MA NON a inizio riga (ci sono spazi prima?)."
    else
        echo "   ❌ Grep NON trova 'border-color=' nel template!"
    fi
else
    echo "   ❌ FATAL: Il file template non esiste!"
    exit 1
fi

# 3. TEST DI COPIA
echo -e "\n2. TEST COPIA:"
rm -f "$TARGET"
cp "$TEMPLATE" "$TARGET"
if [ -s "$TARGET" ]; then
    echo "   ✅ File copiato in $TARGET"
else
    echo "   ❌ Errore: Il file copiato è vuoto."
    exit 1
fi

# 4. TEST DI SOSTITUZIONE (SED)
echo -e "\n3. TENTATIVO DI SOSTITUZIONE (SED):"
echo "   Colore target: $TEST_COLOR"

# Proviamo la sostituzione standard
sed -i "s/^border-color=.*/border-color=$TEST_COLOR/" "$TARGET"

# 5. VERIFICA RISULTATO
echo -e "\n4. RISULTATO FINALE:"
RESULT=$(grep "border-color" "$TARGET")
echo "   Riga nel file config: '$RESULT'"

if [[ "$RESULT" == *"FF00FF"* ]]; then
    echo "   🎉 SUCCESSO! Il colore è cambiato."
else
    echo "   💀 FALLITO. Il colore è rimasto quello originale."
    echo "   Possibili cause: Caratteri nascosti, spazi o encoding (DOS/Windows)."
fi
echo "==================================================="
