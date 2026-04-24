# Guerova (Laravel API + React)

Estrutura:

- `backend/`: Laravel (API)
- `frontend/`: **ArchitectUI React** (Vite) — base pública [architectui-react-theme-free](https://github.com/DashboardPack/architectui-react-theme-free), com proxy `/api` para o Laravel. O app comercial em [react.architectui.com](https://react.architectui.com/) (PRO) pode substituir este `frontend/` mantendo o `vite.config.js` (porta + proxy).
- `frontend-legacy-vite/`: scaffold Vite mínimo anterior (backup).

## Pré-requisitos (Windows)

- Docker Desktop **rodando** (Engine Linux / `desktop-linux`)
- Node.js **>= 22.12** (e npm >= 10 recomendado)

- Se o Docker não responder, abra o **Docker Desktop** até o engine ficar ativo.
- Se existir **Node 16** no PATH à frente do Node 20+, use `npm install --legacy-peer-deps` ou invoque o `npm-cli.js` com Node 20+ (veja `engines` no `frontend/package.json`).

## Subir o backend (Laravel) via Docker

1. Inicie o Docker Desktop
2. Rode o script abaixo no PowerShell:

```powershell
cd c:\Projetos\Guerova
.\scripts\create-backend.ps1
```

Depois disso, o Laravel deve ficar em `http://localhost:8000` e a rota `GET /api/health` deve responder JSON.

## Subir o frontend (React)

```powershell
cd c:\Projetos\Guerova\frontend
npm install --legacy-peer-deps
npm run dev
```

O Vite usa `VITE_PORT` (padrão **5173** no `.env`) e faz **proxy** de `/api/*` para `VITE_API_PROXY_TARGET` (padrão `http://127.0.0.1:8000`).

## Template PRO (react.architectui.com)

O site [react.architectui.com](https://react.architectui.com/) é o produto **PRO** (ZIP / repositório privado após compra). Depois de baixar o pacote, substitua o conteúdo de `frontend/` pelo do PRO e **reaplique** no `vite.config.*`: `server.port`, `strictPort`, `server.proxy['/api']` e `VITE_API_PROXY_TARGET`, para continuar integrado ao Laravel.

"# Guerova" 
