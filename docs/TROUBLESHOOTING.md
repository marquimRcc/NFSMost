# Guia Técnico de Resolução de Problemas (Troubleshooting)

Este documento reúne todas as causas-raiz identificadas e soluções validadas para a execução de **Need for Speed: Most Wanted (2005) - Project Hanami v3.0** no Linux sob Wine/Proton e DXVK.

---

## 1. Janela "Unable to load NFSMW_XenonEffects.asi. Error: 203"

### Sintoma
Ao iniciar o jogo, surge uma janela modal do *Ultimate ASI Loader* com o erro:
```
Unable to load NFSMW_XenonEffects.asi. Error: 203
```
Se o jogo estiver em tela cheia, essa janela fica oculta por trás, travando a interface gráfica ou fechando o jogo silenciosamente.

### Causa
O módulo `NFSMW_XenonEffects.asi` foi compilado com dependências da CRT moderna da Microsoft (`api-ms-win-crt-*` / `vcruntime140.dll` / `msvcp140.dll`). No modo Wine wow64 experimental, a inicialização dessa biblioteca falha com o código de erro Win32 `203` (`ERROR_ENVVAR_NOT_FOUND`).

### Solução
Desative o plugin renomeando a extensão:
```bash
mv scripts/NFSMW_XenonEffects.asi scripts/NFSMW_XenonEffects.asi.bak
```
Os efeitos principais do Hanami v3.0 continuam ativos via `NFSMWCustomShaders.asi` e `NFSMWHDReflections.asi`.

---

## 2. Jogo abre e fecha imediatamente ("Abre e fecha a janela")

### Sintomas
O jogo cria uma janela preta por 1 a 2 segundos e fecha abruptamente, sem mensagens na tela. No log do DXVK/Wine consta:
```
D3D9DeviceEx::ResetSwapChain: Requested Presentation Parameters - Windowed: false
Setting display mode: 2560x1440@0
wine: Unhandled page fault on write access to 00000000 at address 7B53AD32
```

### Causa
Com `WindowedMode = 0` (fullscreen exclusivo) no arquivo `NFSMostWanted.WidescreenFix.ini`, o jogo solicita ao Direct3D9 a troca de resolução e taxa de atualização do monitor (`ChangeDisplaySettings`). Em monitores de alta taxa de atualização (ex: 165Hz) e drivers Vulkan (RADV) via Wine wow64, o swapchain falha ao criar o backbuffer exclusivo.

### Solução
Altere a propriedade `WindowedMode` para `1` (Borderless / Janela Sem Bordas) em `scripts/NFSMostWanted.WidescreenFix.ini`:
```ini
[MISC]
WindowedMode = 1
```
No modo borderless, o jogo ocupa toda a tela na resolução nativa do seu monitor (ex: 2560x1440) sem disparar troca física de display mode.

---

## 3. Travamento total do sistema / Tela congelada no Linux

### Sintoma
Caso o jogo sofra qualquer falha em tela cheia, o mouse fica preso, o teclado não responde e a tela congela.

### Causa
Por padrão, o Wine ativa o depurador interno `winedbg.exe` quando ocorre uma exceção. Esse processo abre uma janela modal no Windows invisível no Linux enquanto o cursor do mouse e o foco do X11/Wayland continuam capturados pelo Wine.

### Solução
1. Desative o `AeDebug` no registro do Wine:
   ```bash
   wine reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /d 0 /f
   ```
2. Adicione os overrides no script de inicialização (`run_game.sh`):
   ```bash
   export WINEDLLOVERRIDES="...;winemenubuilder=d;winedbg.exe=d;winedbg=d"
   ```

---

## 4. Cenário preto / Apenas carros, fumaça e sol visíveis (AMD Radeon)

### Sintoma
Os modelos 3D dos carros, fumaça de pneus e o sol renderizam perfeitamente, porém asfalto, calçadas, prédios e vegetação ficam totalmente escuros ou ausentes.

### Causa
1. **Nível de Detalhe no Mínimo**: Na primeira execução, o registro do jogo salva `g_WorldLodLevel = 0`. Os shaders modificados do Hanami exigem nível máximo de geometria do mundo. Com LOD 0, a distância de desenho das malhas da cidade cai para zero.
2. **Shaders Xbox 360 Incompatíveis com DXVK**: O plugin `XNFS-ShaderLoader-MW.asi` injeta shaders do Xbox 360 (`IDI_WORLD_FX`, `IDI_TREE_FX`) que podem falhar na compilação HLSL para SPIR-V no RADV.

### Solução
1. Forçar configurações gráficas máximas no registro:
   ```bash
   wine regedit configs/nfs_graphics_settings.reg
   ```
   Valores chave:
   - `g_WorldLodLevel = 3` (Máximo)
   - `g_RoadReflectionEnable = 2` (Alto)
   - `g_ShadowDetail = 2` (Alto)
   - `g_TextureFiltering = 2` (Anisotrópica)
   - `g_OverBrightEnable = 1`
   - `g_VisualTreatment = 1`
2. Adicionar o arquivo `dxvk.conf` na raiz do jogo com otimizações para AMD:
   ```ini
   d3d9.lenientClear = True
   d3d9.floatEmulation = strict
   d3d9.customVendorId = 1002
   ```

---

## 5. Falha de Compilação de Shaders (`vkd3d result -4` / `ID3DXEffectPool`)

### Sintoma
O jogo fecha na inicialização com erros de compilação de efeitos D3DX no terminal.

### Causa
As bibliotecas `d3dx9_36.dll`, `d3dcompiler_43.dll` e `d3dcompiler_47.dll` embutidas no Wine possuem implementações parciais ou com bugs de compatibilidade com o Ultimate ASI Loader e shaders DirectX 9.0c.

### Solução
Instalar os runtimes oficiais do Microsoft DirectX June 2010 (versões x86 de 32 bits):
- `d3dx9_36.dll`
- `d3dx9_43.dll`
- `d3dcompiler_43.dll`
- `d3dcompiler_47.dll`
E configurar `WINEDLLOVERRIDES="d3dx9_36=n,b;d3dx9_43=n,b;d3dcompiler_43=n,b;d3dcompiler_47=n,b"`.
