# Guia Técnico de Resolução de Problemas (Troubleshooting)

Este documento reúne todas as causas-raiz identificadas e soluções validadas para a execução de **Need for Speed: Most Wanted (2005) - Project Hanami v3.0** no Windows (nativo) e no Linux (Wine/Proton).

---

## 1. Problemas Específicos do Windows

### 1.1. Cenário preto ou asfalto escuro (AMD Radeon RX 6000 / 7000)
- **Sintoma**: Carros, céu e sol aparecem normais, mas a pista, calçadas ou prédios ficam escuros ou sem textura.
- **Causa**: Os drivers modernos AMD Adrenalin possuem regressões no pipeline de sombreamento D3D9 legado em placas RDNA2/RDNA3 (ex: RX 6750 XT).
- **Solução**:
  1. Copie os arquivos da pasta `AMD FIX` (`d3d9.dll`, `dgVoodoo.conf`, `dxgi.dll`) para a raiz do jogo (ao lado de `speed.exe`).
  2. O dgVoodoo converterá as chamadas para D3D11 moderno, que roda perfeitamente na RX 6750 XT.
  3. Aplique `configs/nfs_graphics_settings_user.reg` para garantir `g_WorldLodLevel = 3`.

### 1.2. O jogo fecha silenciosamente ao clicar em Iniciar
- **Sintoma**: Ao abrir `speed.exe`, o ponteiro do mouse gira por 2 segundos e nada acontece.
- **Causa 1**: Ausência de runtimes do Visual C++ 2015-2022 de **32 bits (x86)**. Como o jogo é um binário x86, instalar apenas o VC++ x64 não resolve.
  - **Correção**: Execute `_Redist\vcredist_2015-2019_x86.exe` (ou baixe o pacote oficial da Microsoft).
- **Causa 2**: Falta de runtimes do DirectX 9.0c (ex: `d3dx9_36.dll`).
  - **Correção**: Execute `_Redist\dxwebsetup.exe`.

### 1.3. Crash com mensagem de DEP (Prevenção de Execução de Dados)
- **Sintoma**: Erro de violação de acesso em `speed.exe`.
- **Causa**: Executáveis antigos de 2005 utilizam modificação dinâmica de código na memória incompatível com o DEP restrito do Windows.
- **Solução**:
  1. Abra as **Propriedades do Sistema** (`sysdm.cpl`).
  2. Vá na aba **Avançado** -> **Desempenho** (Configurações) -> **Prevenção de Execução de Dados**.
  3. Marque "Ativar a DEP para todos os programas, exceto os que eu selecionar" e adicione o `speed.exe`.

### 1.4. Alternar janela (Alt+Tab) trava o jogo
- **Sintoma**: Ao usar Alt+Tab para navegar no Windows, o jogo congela ou perde a resolução.
- **Causa**: Fullscreen exclusivo legado do Direct3D9.
- **Solução**: Mantenha `WindowedMode = 1` em `scripts/NFSMostWanted.WidescreenFix.ini`. O modo Janela Sem Bordas (Borderless) preenche toda a tela e permite Alt+Tab instantâneo sem instabilidade.

---

## 2. Problemas Específicos do Linux (Wine / Proton)

### 2.1. Janela "Unable to load NFSMW_XenonEffects.asi. Error: 203"
- **Sintoma**: Modal de erro do Ultimate ASI Loader com erro Win32 `203` (`ERROR_ENVVAR_NOT_FOUND`).
- **Causa**: Módulo compilado com dependências da CRT moderna da Microsoft que falham no Wine wow64 experimental.
- **Solução**:
  ```bash
  mv scripts/NFSMW_XenonEffects.asi scripts/NFSMW_XenonEffects.asi.bak
  ```

### 2.2. Jogo abre e fecha imediatamente ("Abre e fecha a janela")
- **Sintoma**: DXVK/Wine reporta falha de swapchain ao tentar mudar o modo de vídeo a 165Hz em fullscreen exclusivo (`WindowedMode = 0`).
- **Solução**: Use `WindowedMode = 1` em `scripts/NFSMostWanted.WidescreenFix.ini`.

### 2.3. Travamento total do sistema / Tela congelada no Wine
- **Sintoma**: Wine abre o depurador interno `winedbg.exe` invisível enquanto retém o foco do teclado e do mouse.
- **Solução**:
  ```bash
  wine reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /d 0 /f
  export WINEDLLOVERRIDES="...;winemenubuilder=d;winedbg.exe=d;winedbg=d"
  ```

### 2.4. Controle não responde no Linux
- **Sintoma**: Botões ou analógicos do controle não são detectados.
- **Causa**: Presença de `xinput1_3.dll` legada (x360ce) na raiz do jogo sequestrando as chamadas do Winebus.
- **Solução**:
  ```bash
  mv xinput1_3.dll xinput1_3.dll.bak
  export SDL_JOYSTICK_HIDAPI=1
  export WINEDLLOVERRIDES="...;xinput1_3=b;xinput1_4=b;xinput9_1_0=b"
  ```
