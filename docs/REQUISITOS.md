# Documento de Requisitos — App Bem Estar Cem (E-commerce)

**Cliente:** Bem Estar Cem | **Data:** 2026-08-03 | **Versão:** 1.0
**Responsável:** DevOps Manager / Analista de Requisitos | **Status:** Rascunho — aguardando validação do cliente

---

## 1. Visão Geral

A empresa Bem Estar Cem hoje vende de forma física/tradicional e quer migrar para o
e-commerce, começando pela venda de **móveis e eletrodomésticos**. O objetivo do app é
oferecer uma vitrine digital moderna e atraente, com todo o fluxo de compra completo
(catálogo, carrinho, pagamento via cartão e Pix, e acompanhamento de entrega), operando
inicialmente sobre o **estoque local** da empresa, com evolução planejada para também
consultar o **estoque dinâmico de fornecedores parceiros**.

Já existe um app Flutter em estágio inicial (login/cadastro, listagem e detalhe de
produto) conectado a um projeto Firebase próprio — ver [README.md](../README.md) para o
estado atual do código. Este documento trata do produto completo a ser construído a
partir dessa base.

## 2. Stakeholders

| Papel | Nome/Área | Responsabilidade |
|-------|----------|-------------------|
| Cliente / Patrocinador | Bem Estar Cem | Define prioridades de negócio, aprova escopo e orçamento |
| Usuário final | Consumidor comprando móveis/eletrodomésticos | Navega, compra e acompanha pedidos no app |
| Operação / Estoque | Time interno da loja | Mantém estoque local e cadastro de produtos atualizados |
| Fornecedores | Parceiros de móveis/eletrodomésticos | Fornecem estoque dinâmico via integração (API/EDI) |
| DevOps Manager | Techindev | Requisitos, CI/CD, infraestrutura |
| Mobile Architect/Senior | Techindev | Arquitetura e implementação do app Flutter |
| Backend | Techindev | API de catálogo, pedidos, pagamento, integração com fornecedores |
| QA | Techindev | Testes e homologação |

## 3. Requisitos Funcionais

| ID | Descrição | Prioridade | Critério de Aceite |
|----|-----------|------------|---------------------|
| RF-001 | Cadastro e login de usuário (e-mail/senha) | 🔴 Must | Usuário cria conta, confirma e-mail (se aplicável) e faz login com sucesso |
| RF-002 | Login social (Google/Apple) | 🟡 Should | Usuário entra com 1 toque via conta Google/Apple |
| RF-003 | Catálogo de produtos com categorias (móveis, eletrodomésticos) | 🔴 Must | Produtos listados por categoria, com filtro e paginação |
| RF-004 | Busca de produtos por nome/categoria | 🔴 Must | Resultado retorna em <2s para termos parciais |
| RF-005 | Página de detalhe do produto (fotos, descrição, preço, parcelamento, estoque) | 🔴 Must | Exibe galeria de imagens, preço à vista e parcelado, disponibilidade |
| RF-006 | Indicação de origem do estoque (loja própria vs. fornecedor) | 🟡 Should | UI diferencia "Envio imediato" (estoque local) de "Sob encomenda" (fornecedor) |
| RF-007 | Carrinho de compras | 🔴 Must | Adicionar/remover/alterar quantidade, subtotal calculado corretamente |
| RF-008 | Checkout com endereço de entrega | 🔴 Must | Usuário informa/seleciona endereço, frete é calculado antes da confirmação |
| RF-009 | Pagamento via cartão de crédito no app | 🔴 Must | Integração com gateway (tokenização, sem armazenar dados do cartão no app) |
| RF-010 | Pagamento via Pix no app (QR Code + copia-e-cola) | 🔴 Must | QR gerado na hora, confirmação automática via webhook em até 60s |
| RF-011 | Histórico de pedidos do usuário | 🔴 Must | Lista pedidos com status atualizado |
| RF-012 | Acompanhamento de entrega (rastreio/status) | 🔴 Must | Status visível: confirmado → separação → em transporte → entregue |
| RF-013 | Notificações push (status de pedido, promoções) | 🟡 Should | Usuário recebe push ao mudar o status do pedido |
| RF-014 | Avaliação de produto/compra | 🟢 Could | Usuário avalia produto após entrega confirmada |
| RF-015 | Painel administrativo de catálogo e pedidos (web) | 🔴 Must | Operação da loja cadastra/edita produtos e acompanha pedidos |
| RF-016 | Integração com estoque dinâmico de fornecedores | 🟡 Should (fase 2) | Disponibilidade do fornecedor refletida no app em até X min (definir com fornecedor) |
| RF-017 | Cupom de desconto / frete grátis | 🟢 Could | Usuário aplica cupom válido no checkout |
| RF-018 | Wishlist / favoritos | 🟢 Could | Usuário salva produtos para comprar depois |

## 4. Requisitos Não-Funcionais

| ID | Categoria | Requisito | Métrica |
|----|-----------|-----------|---------|
| RNF-001 | Performance | Tempo de carregamento do catálogo | < 2s p95 em 4G |
| RNF-002 | Disponibilidade | Uptime da API/backend | 99.5% mensal |
| RNF-003 | Segurança | Dados de pagamento | Nunca trafegam/armazenam PAN no app — apenas tokenização via gateway PCI-DSS |
| RNF-004 | Segurança | Autenticação | Firebase Auth / OAuth2, tokens com expiração e refresh |
| RNF-005 | Compatibilidade | Dispositivos suportados | Android 8+ (API 26+) e iOS 14+ |
| RNF-006 | UX/Design | Identidade visual moderna e responsiva | Design system próprio, dark/light mode |
| RNF-007 | Escalabilidade | Suporte a crescimento de catálogo/fornecedores | Backend deve suportar múltiplos fornecedores sem redesenho |
| RNF-008 | Observabilidade | Rastreabilidade de erros de pagamento/pedido | Logs e alertas em produção (Sentry/Crashlytics) |
| RNF-009 | Conformidade | LGPD | Consentimento de dados, política de privacidade, direito de exclusão |
| RNF-010 | Conformidade | PCI-DSS (via gateway terceirizado) | Certificação do gateway de pagamento verificada |

## 5. Restrições

- **Plataforma:** App mobile (Flutter — Android/iOS), com necessidade de painel web administrativo
- **Estoque:** Híbrido — estoque local (fonte de verdade inicial) + integração futura com estoque de fornecedores (API a ser definida por fornecedor)
- **Pagamento:** Cartão de crédito e Pix diretamente no app — requer gateway de pagamento homologado no Brasil
- **Prazo:** Não informado pelo cliente — *pergunta aberta (ver seção 9)*
- **Orçamento:** Não informado pelo cliente — *pergunta aberta*
- **Regulatório:** LGPD (dados pessoais), PCI-DSS (pagamento, via gateway terceirizado), regras do Banco Central para Pix (uso de PSP habilitado)

## 6. Áreas Envolvidas

- [x] Mobile (Flutter) — app do consumidor
- [x] Backend (Python/Django ou FastAPI) — API de catálogo, pedidos, pagamento, integração com fornecedores
- [x] Frontend (React) — painel administrativo web (catálogo/pedidos/estoque)
- [x] DevOps/Infra — CI/CD, ambientes, observabilidade
- [ ] Firmware / Embedded Linux — não aplicável a este projeto

## 7. Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Ausência de gateway de pagamento definido (cartão/Pix) | Alta | Alto | Definir gateway (ex: Mercado Pago, Pagar.me, Stripe+Pix via PSP) na fase de arquitetura, antes de iniciar checkout |
| Integração com estoque de fornecedores sem padrão definido (cada fornecedor pode ter API diferente) | Alta | Médio | Criar camada de adapter/anti-corruption layer no backend; priorizar 1 fornecedor piloto |
| App legado usa pacotes Firebase e Flutter desatualizados | Confirmado | Médio | Já mitigado nesta rodada: SDK/toolchain e dependências atualizadas (ver README) |
| Falta de definição de prazo/orçamento do cliente | Alta | Médio | Levantar com o cliente antes de comprometer cronograma |
| Dados de pagamento em app mobile (risco de segurança) | Média | Alto | Nunca processar/armazenar dados de cartão no app; usar SDK do gateway com tokenização |

## 8. Cronograma de Alto Nível (estimativa preliminar — T-shirt sizing)

| Fase | Tamanho | Entregável |
|------|---------|-----------|
| Requisitos (este documento) | P (concluído) | Documento de requisitos v1.0 |
| Arquitetura (mobile + backend + integração fornecedor + pagamento) | M | ADRs de arquitetura por área |
| MVP (catálogo estoque local + carrinho + checkout cartão/Pix + acompanhamento de entrega) | GG | App funcional com fluxo de compra completo sobre estoque local |
| Integração com fornecedores (estoque dinâmico) | G | Fase 2, após MVP validado |
| QA / Homologação | M | Relatório de testes, testes em dispositivos reais |
| Deploy (lojas + backend produção) | M | App nas lojas (Play Store/App Store) + backend em produção |

## 9. Perguntas Abertas (precisam de resposta do cliente)

1. **Pagamento:** Já existe um gateway de pagamento definido/contratado (ex: Mercado Pago, Pagar.me, Cielo, Stripe)? Ou a escolha fica a cargo do time técnico?
2. **Fornecedores:** Quais fornecedores serão integrados primeiro e que tipo de integração eles oferecem (API REST, webhook, EDI, planilha)?
3. **Entrega:** A entrega é feita por transportadora própria, terceirizada (Correios/transportadoras) ou por um serviço de rastreio já contratado?
4. **Estoque local:** Existe hoje algum sistema de gestão (ERP/PDV) com o estoque local, ou os produtos serão cadastrados do zero no novo backend?
5. **Prazo e orçamento:** Existe uma data alvo de lançamento (ex: para uma sazonalidade específica) e um teto de orçamento?
6. **Escopo de plataformas:** Além do app mobile, é necessário site/e-commerce web para o mesmo catálogo, ou o foco inicial é só mobile?
7. **Identidade visual:** Já existe manual de marca/design (logo, cores, tipografia) da Bem Estar Cem a seguir, ou o design fica livre para a equipe propor?
8. **Volume esperado:** Estimativa de número de produtos no catálogo e de pedidos/mês, para dimensionar a infraestrutura desde o início.

## 10. Recomendação de Equipe

- **Mobile:** 1 Architect (definição inicial) + 1–2 Senior Flutter Developers
- **Backend:** 1 Architect + 1–2 Senior Python (Django/FastAPI) para catálogo, pedidos e integração de pagamento/fornecedores
- **Frontend:** 1 Senior React para painel administrativo
- **DevOps:** 1 DevOps para CI/CD, ambientes (dev/staging/prod) e observabilidade
- **QA:** 1 QA dedicado a partir do início do MVP

## 11. Próximos Passos

| Ação | Responsável | Quando |
|------|-------------|--------|
| Validar este documento e responder perguntas abertas (seção 9) | Cliente | Antes do início da fase de arquitetura |
| Definir gateway de pagamento (cartão + Pix) | DevOps + Backend Architect | Início da fase de arquitetura |
| Desenhar arquitetura do backend (catálogo, pedidos, pagamento, adapter de fornecedores) | Backend Architect | Após validação do cliente |
| Desenhar arquitetura mobile (Clean Architecture, navegação, estado) | Mobile Architect | Em paralelo à arquitetura de backend |
| Priorizar backlog do MVP a partir dos RF listados | Todos | Após arquitetura definida |
