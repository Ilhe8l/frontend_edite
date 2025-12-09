# Sistema de Gestão de Editais FAPES

Sistema de gestão de editais desenvolvido com Vue.js 3, TypeScript e TailwindCSS, seguindo o padrão modular LEDS.

## 📋 Pré-requisitos

- Node.js 18+ ou 20+
- npm ou pnpm
- Acesso à VPN (para produção)

## 🚀 Instalação

```bash
# Instalar dependências
npm install
```

## ⚙️ Configuração

### Variáveis de Ambiente

O projeto possui 3 arquivos de ambiente:

- `.env.development` - Desenvolvimento (mock ou VPN)
- `.env.production` - Produção
- `.env.vpn` - Configuração específica para VPN

### Modo Mock (Desenvolvimento Offline)

```bash
# .env.development
VITE_API_BASE_URL=http://localhost:3001/api
VITE_USE_MOCK=true
```

### Modo VPN (Desenvolvimento com Django)

```bash
# .env.development
VITE_API_BASE_URL=https://controlpanel.aws.leds.dev.br/api
VITE_USE_MOCK=false
```

## 🛠️ Desenvolvimento

```bash
# Iniciar servidor de desenvolvimento
npm run dev

# Build para produção
npm run build

# Preview do build
npm run preview
```

O servidor estará disponível em `http://localhost:3000`

## 📁 Estrutura do Projeto (Padrão LEDS)

```
src/
├── common/                    # Código compartilhado
│   ├── api/                   # Configuração de API
│   ├── assets/                # Assets globais
│   ├── components/            # Componentes globais
│   │   └── ui/                # Componentes UI base
│   ├── constants/             # Constantes
│   ├── plugins/               # Plugins Vue
│   ├── router/                # Router principal
│   ├── store/                 # Stores Pinia globais
│   ├── types/                 # Types TypeScript
│   ├── utils/                 # Utilitários
│   └── globalComponents.ts   # Registro de componentes
│
├── layouts/                   # Layouts
│   ├── AppHeader.vue
│   └── PageContainer.vue
│
├── modules/                   # Módulos da aplicação
│   ├── autenticacao/          # Login e autenticação
│   ├── gestao-editais/        # Gestão de editais
│   ├── metricas/              # Métricas e analytics
│   └── historico/             # Histórico de conversas
│
├── App.vue                    # Componente raiz
└── main.ts                    # Entry point
```

## 🔌 Integração com Django

### Início Rápido

```bash
# 1. Alternar para modo VPN
./switch-mode.sh vpn

# 2. Reiniciar servidor
npm run dev

# 3. Fazer login com credenciais do Django
```

### Documentação Completa

- `START_HERE.md` - Guia de início rápido
- `DJANGO_CORS_CONFIG.txt` - Configuração CORS
- `check-django-endpoints.sh` - Verificar endpoints
- `ENDPOINT_MAPPING.md` - Mapeamento de endpoints

## 🧪 Testes

```bash
# Executar testes
npm run test

# Testes em modo watch
npm run test:watch

# Coverage
npm run test:coverage
```

## 📦 Build e Deploy

### Build

```bash
npm run build
```

Os arquivos otimizados serão gerados na pasta `dist/`.

### Docker

```bash
# Build da imagem
docker build -t gestao-editais-fapes .

# Executar container
docker run -p 80:80 gestao-editais-fapes
```

## 🔐 Autenticação

O sistema usa JWT (JSON Web Tokens) para autenticação:

- Access token: válido por 1 hora
- Refresh token: válido por 7 dias
- Tokens armazenados em localStorage
- Renovação automática de tokens

## 🎨 Componentes UI

O projeto usa componentes base customizados:

- Button
- Card
- Input
- Select
- Alert
- Badge
- Tabs
- Spinner
- Logo

## 📊 Módulos

### 1. Autenticação
- Login com email/senha
- Logout
- Renovação automática de tokens

### 2. Gestão de Editais
- Listagem de editais
- Criação/edição de editais
- Upload de arquivos
- Campos dinâmicos

### 3. Métricas
- Métricas de engajamento
- Gráficos interativos
- Listagem de mensagens

### 4. Histórico
- Histórico de conversas
- Visualizador de chat
- Busca de sessões

## 🔧 Scripts Úteis

```bash
# Alternar entre mock e VPN
./switch-mode.sh [mock|vpn]

# Testar conexão com Django
./check-django-endpoints.sh

# Testar conexão
./test-connection.sh
```

## 📝 Licença

Proprietário - FAPES

## 👥 Equipe

Desenvolvido para FAPES - Fundação de Amparo à Pesquisa e Inovação do Espírito Santo
