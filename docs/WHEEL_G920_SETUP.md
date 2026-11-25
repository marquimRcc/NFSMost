# Guia de Configuração: Volante Logitech G920 (Windows)

Este guia prepara e documenta o uso do **Logitech G920 Driving Force** no **Need for Speed: Most Wanted (2005) - Project Hanami v3.0 (Dublado PT-BR)**.

> [!NOTE]
> O suporte ao volante funciona em paralelo com a dublagem PT-BR e todos os mods gráficos do Hanami v3.0. Como o motor do jogo é de 2005 (era DirectInput) e arcade, os ajustes abaixo evitam bugs de menu e deixam a direção responsiva.

---

## 1. Preparação no Logitech G HUB (Obrigatório)

Antes de abrir o jogo, conecte o G920, abra o **Logitech G HUB** e crie/ajuste o perfil para `speed.exe`:

1. **Ângulo de Operação (Rotação):**
   - Altere de `900°` para **`270°` a `360°`**.
   - *Motivo:* Jogos arcade de 2005 não foram feitos para 900°; com rotação menor você faz curvas fechadas e desvios de trânsito rapidamente.
2. **Mola de Centralização em Jogos com Force Feedback:**
   - **Ativada**, entre **10% e 20%**.
   - *Motivo:* O Force Feedback antigo do MW 2005 é básico e às vezes não centraliza o volante sozinho.
3. **Força Geral / Mola / Amortecedor:**
   - **100%** no G HUB (ajuste fino depois dentro do jogo se achar pesado).
4. **Pedais Combinados (Combined Pedals) — Solução para menu travado:**
   - Caso ao abrir o jogo o menu fique **rolando sozinho sem parar**, marque a opção **Pedais Combinados (Combined Pedals)** nas configurações do G920 no G HUB.
   - *Motivo:* Jogos antigos da Black Box usam eixos DirectInput legados que interpretam os pedais separados (acelerador + freio em repouso) como uma tecla pressionada continuamente.

---

## 2. Alternar o Jogo para Modo Volante

Para evitar que o hook de XInput do `WidescreenFix` (usado pelo controle 8BitDo/Xbox) interfira nos eixos do G920:

1. Execute o script interativo:
   ```cmd
   scripts\windows\switch_input_profile.bat
   ```
   E escolha a opção **`[2] Modo Volante (Logitech G920 - DirectInput)`**.
2. Ou via PowerShell:
   ```powershell
   .\scripts\windows\switch_input_profile.ps1 -Mode wheel
   ```
   *(Isso ajusta `ImproveGamepadSupport = 3` e `LeftStickDeadzone = 0.0` no `NFSMostWanted.WidescreenFix.ini`)*.

> [!TIP]
> Quando quiser voltar a jogar no controle **8BitDo / Xbox**, basta rodar o mesmo script escolhendo a opção **`[1] Modo Controle`** (ou `-Mode gamepad`).

---

## 3. Mapeamento Dentro do Jogo (`Opções > Controles`)

Com o G920 já conectado **antes** de abrir `speed.exe`:

1. Vá em **Opções > Controles**.
2. **Direção Esquerda / Direita:** Ao clicar para mapear, **gire o volante todo até o batente** (máximo à esquerda ou à direita) para garantir que o jogo reconheça o eixo analógico suave em vez de um clique digital.
3. **Acelerador e Freio/Ré:** Pressione o pedal correspondente até o fundo ao mapear.
4. **Sensibilidade e Zona Morta:**
   - **Zona Morta (Deadzone):** `0%` (ou o menor valor que não trema em linha reta).
   - **Sensibilidade da Direção:** **Alta / Máxima** para acompanhar a física arcade.
5. **Force Feedback vs Vibração:**
   - Deixe **Force Feedback: Ligado**.
   - Se os trancos de colisão na mesa forem muito violentos nas engrenagens do G920, deixe **Vibração: Desligada** e use apenas o Force Feedback básico.

---

## 4. Solução Rápida de Problemas com o Volante

| Sintoma | Causa | Solução |
| :--- | :--- | :--- |
| **Menu descendo/rolando sozinho** | Eixos separados dos pedais no DirectInput | Ative **Pedais Combinados** no Logitech G HUB (ou dê um toque de meio curso no pedal para parar enquanto navega). |
| **Volante vira pouco nas curvas** | Rotação de 900° ativa no G HUB | Reduza o ângulo no G HUB para **270°–360°** e aumente a sensibilidade no menu do jogo. |
| **Jogo não reconhece o G920** | Volante conectado após abrir o jogo ou conflito XInput | Conecte antes de iniciar, rode `switch_input_profile.ps1 -Mode wheel` e confira no `joy.cpl` do Windows. |
