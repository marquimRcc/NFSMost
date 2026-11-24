# Configuração de Controles e Gamepads no Linux

Este guia explica como configurar controles modernos (como **8BitDo Ultimate 2 Wireless**, controles de Xbox Series/One, DualShock 4 e DualSense) no Need for Speed: Most Wanted (2005) rodando via Wine no Linux.

---

## 1. O Problema da DLL `xinput1_3.dll` Legada

Muitos pacotes e mods do NFS Most Wanted vêm acompanhados de uma DLL `xinput1_3.dll` de 32 bits pré-instalada na raiz do jogo. Geralmente trata-se de um wrapper legado do **x360ce** projetado para Windows XP/7.

### Por que isso quebra o controle no Linux?
No Linux, o Wine utiliza o driver de kernel `evdev` e a biblioteca `SDL2` através do subsistema `winebus.sys` para traduzir os botões e eixos analógicos diretamente para as APIs XInput do Windows. 

Quando existe um arquivo `xinput1_3.dll` de terceiros na pasta do jogo:
1. O jogo carrega a DLL local em vez da biblioteca nativa do Wine.
2. A DLL local tenta acessar chamadas de hook do Windows que não existem no Linux.
3. **Resultado**: O jogo não detecta nenhum botão ou alavanca analógica do controle.

### Solução Definitiva
1. Renomeie a DLL na raiz do jogo:
   ```bash
   mv xinput1_3.dll xinput1_3.dll.bak
   ```
2. No script de inicialização, force o uso dos drivers internos do Wine:
   ```bash
   export WINEDLLOVERRIDES="...;xinput1_3=b;xinput1_4=b;xinput9_1_0=b"
   export SDL_JOYSTICK_HIDAPI=1
   ```

---

## 2. Ícones de Botões na Interface (HUD)

O plugin **NFSMostWanted.WidescreenFix.asi** possui suporte nativo para substituir as teclas de teclado da interface gráfica pelos ícones oficiais do controle.

Abra `scripts/NFSMostWanted.WidescreenFix.ini`:
```ini
[MISC]
; 1 = Ícones do Xbox (A, B, X, Y, LB, RB, LT, RT)
; 2 = Ícones do PlayStation (Cruz, Círculo, Quadrado, Triângulo, L1, R1, L2, R2)
; 3 = Desativado
ImproveGamepadSupport = 1

; Zona morta do analógico esquerdo (volante)
LeftStickDeadzone = 10.0
```

---

## 3. Mapeamento Recomendado no Menu do Jogo

Ao entrar em **Opções -> Controles**:
- **Acelerar**: Gatilho Direito (RT / R2) ou Botão A / Cruz
- **Frear / Ré**: Gatilho Esquerdo (LT / L2) ou Botão X / Quadrado
- **Freio de Mão**: Botão B / Círculo
- **Nitro (NOS)**: Botão A ou LB / L1
- **Speedbreaker**: Analógico Direito ou RB / R1
- **Direção**: Analógico Esquerdo (X-Axis)
- **Câmera**: Analógico Direito ou D-Pad
