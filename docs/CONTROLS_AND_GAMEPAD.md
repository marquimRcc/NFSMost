# Configuração de Controles e Gamepads (Windows & Linux)

Este guia explica como configurar controles modernos (como **8BitDo Ultimate 2 Wireless**, controles de Xbox Series/One, DualShock 4 e DualSense) no Need for Speed: Most Wanted (2005) - Project Hanami.

---

## 1. Comportamento no Windows

No Windows 10 e 11, o suporte ao controle é **nativo via XInput**:
- **8BitDo Ultimate 2**: Use a chave seletora traseira na posição **2.4G** ou **X** (XInput). O Windows reconhecerá o dispositivo imediatamente como um "Xbox 360 Controller for Windows".
- **Controles de Xbox (One / Series)**: Plug-and-play instantâneo via receptor sem fio, Bluetooth ou cabo USB.
- **Controles de PlayStation (DualShock 4 / DualSense)**: Podem ser usados via DS4Windows ou suporte nativo DirectInput/XInput.

> [!IMPORTANT]
> A DLL `xinput1_3.dll.bak` na raiz do jogo deve permanecer renomeada como `.bak`. Essa DLL pertencia a um emulador legado (x360ce) que interceptava controles antigos DirectInput e causa conflito com as APIs XInput modernas do Windows.

---

## 2. Comportamento no Linux (Wine)

No Linux, o Wine utiliza o driver de kernel `evdev` e a biblioteca `SDL2` através do subsistema `winebus.sys` para traduzir os botões e eixos analógicos:
1. Renomeie qualquer DLL local de xinput:
   ```bash
   mv xinput1_3.dll xinput1_3.dll.bak
   ```
2. Force o uso dos drivers internos do Wine (`winebus` + `SDL2`):
   ```bash
   export WINEDLLOVERRIDES="...;xinput1_3=b;xinput1_4=b;xinput9_1_0=b"
   export SDL_JOYSTICK_HIDAPI=1
   ```

---

## 3. Ícones de Botões na Interface (HUD)

O plugin **NFSMostWanted.WidescreenFix.asi** possui suporte nativo para substituir as teclas de teclado da interface gráfica pelos ícones oficiais do controle.

Arquivo: `scripts/NFSMostWanted.WidescreenFix.ini`:
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

## 4. Mapeamento Recomendado no Menu do Jogo

Ao entrar em **Opções -> Controles**:
- **Acelerar**: Gatilho Direito (RT / R2) ou Botão A
- **Frear / Ré**: Gatilho Esquerdo (LT / L2) ou Botão X
- **Freio de Mão**: Botão B
- **Nitro (NOS)**: Botão A ou LB
- **Speedbreaker**: Analógico Direito ou RB
- **Direção**: Analógico Esquerdo (X-Axis)
- **Olhar para trás**: Analógico Direito (para baixo)
- **Trocar Câmera**: Botão Y

---

## 5. Volante Logitech G920 (Windows)

Para usar o volante **Logitech G920** no Windows sem conflitos com o modo XInput do controle:
- Utilize o script `scripts/windows/switch_input_profile.bat` (ou `switch_input_profile.ps1 -Mode wheel`) para alternar entre **Controle** e **Volante**.
- Consulte o guia dedicado em [docs/WHEEL_G920_SETUP.md](WHEEL_G920_SETUP.md) para ajustes do Logitech G HUB (rotação 270°–360°, Pedais Combinados e Force Feedback).
