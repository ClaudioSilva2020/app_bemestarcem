# Bem Estar Cem — App de E-commerce (Flutter)

Status do projeto em **2026-08-03**. Este documento resume em que ponto o desenvolvimento
está hoje, o que já funciona, o que falta, e como rodar o app localmente. Para o
levantamento de requisitos completo do produto (e-commerce de móveis e eletrodomésticos,
estoque local + fornecedores, pagamento cartão/Pix, entrega), veja
[docs/REQUISITOS.md](docs/REQUISITOS.md).

## Estágio atual: UI completa + Firebase integrado (autenticação, catálogo e carrinho)

O app usa um template de e-commerce completo (baseado no
[flutter_ecommerce_template](https://github.com/robertodevs/flutter_ecommerce_template)),
adaptado para a identidade visual da Bem Estar Cem (cor principal azul, sem nenhuma
referência à marca original do template) e **100% traduzido para português (pt-BR)**.

As telas de **autenticação, catálogo e carrinho já estão ligadas ao Firebase**
(projeto `bemestardata`). O que ainda roda com dados de exemplo são as telas de
pagamento e rastreio de entrega, que dependem de decisões de negócio ainda em aberto
(gateway de pagamento e transportadora — ver [docs/REQUISITOS.md](docs/REQUISITOS.md)).

### Fluxo de abertura do app

Splash → banner de apresentação (3 telas) → login → área logada.
Se o usuário já estiver logado, o app vai direto para a home.

### O que já funciona com dados reais (Firebase)

| Área | Status | Detalhe |
|------|--------|---------|
| Cadastro | ✅ Firebase | Cria conta no Firebase Auth e grava nome/e-mail em `users/{uid}` |
| Login | ✅ Firebase | E-mail/senha via Firebase Auth, com mensagens de erro traduzidas |
| Sessão persistida | ✅ Firebase | Reabrir o app mantém o login e pula direto para a home |
| Recuperação de senha | ✅ Firebase | Envia link de redefinição por e-mail (`sendPasswordResetEmail`) |
| Logout | ✅ Firebase | Em Configurações → Sair; limpa a sessão e volta ao login |
| Catálogo (home, recomendados, detalhe) | ✅ Firestore | Lê a coleção `products`; trata carregamento, erro e catálogo vazio |
| Busca | ✅ Firestore | Filtra o catálogo carregado do Firestore |
| Carrinho | ✅ Firestore | Persistido em `users/{uid}/cart`; adicionar, remover, alterar quantidade |
| Checkout (resumo do carrinho) | ✅ Firestore | Mostra itens reais, quantidade e total em R$ |
| Perfil | ✅ Firebase | Exibe nome e e-mail do usuário logado |

### O que ainda usa dados de exemplo

| Área | Motivo |
|------|--------|
| Pagamento (cartão/Pix) | Depende da escolha do gateway — decisão de negócio em aberto |
| Acompanhamento de entrega | Depende da transportadora/serviço de rastreio a ser contratado |
| Endereço de entrega | Formulário pronto, ainda não persiste no Firestore |
| Notificações / avaliações | Telas estáticas |

### O que ainda não existe

- Gateway de pagamento real (cartão + Pix)
- Pedidos: fechar compra e gravar o pedido no Firestore
- Diferenciação entre estoque local e estoque de fornecedor
- Painel administrativo (cadastro de produto, gestão de pedidos)
- Notificações push
- Testes automatizados

Ver seção 3 (Requisitos Funcionais) de [docs/REQUISITOS.md](docs/REQUISITOS.md) para a
lista priorizada completa.

### Catálogo e categorias

O catálogo tem **10 produtos** cadastrados no Firestore, divididos em 4 categorias
da loja: **Cama**, **Sala**, **Cozinha** e **Eletrodomésticos**.

As categorias são definidas em [lib/models/category.dart](lib/models/category.dart)
(`Category.all`) e usadas em três lugares — abas da home, carrossel de categorias e
aba "Categorias". O campo `category` de cada produto no Firestore **precisa bater
exatamente** com o nome definido ali, senão o produto não aparece na categoria.

### Estrutura de dados no Firestore

```
products/{productId}
  name: string
  description: string
  price: number
  category: string        # "Cama" | "Sala" | "Cozinha" | "Eletrodomésticos"
  images: string[]        # URLs; o app usa a primeira como capa

users/{uid}
  name: string
  email: string
  cart/{itemId}
    productId: string
    quantity: number
```

As regras de segurança estão em [firestore.rules](firestore.rules) e **já foram
publicadas e validadas em produção** (2026-08-03): catálogo com leitura pública e
escrita bloqueada, cadastro e carrinho acessíveis apenas pelo próprio usuário logado.

Verificação feita contra o banco real, via API REST do Firestore:

| Cenário | Resultado |
|---|---|
| Escrita sem login (coleção qualquer) | 🚫 PERMISSION_DENIED |
| Escrita sem login em `products` | 🚫 PERMISSION_DENIED |
| Leitura do catálogo sem login | ✅ 200 OK |
| Leitura de `users` de terceiros | 🚫 PERMISSION_DENIED |
| Usuário logado grava o próprio cadastro | ✅ 200 OK |
| Usuário logado grava/lê o próprio carrinho | ✅ 200 OK |
| Usuário logado grava em cadastro alheio | 🚫 PERMISSION_DENIED |
| Usuário logado altera o catálogo | 🚫 PERMISSION_DENIED |

> Como `products` tem escrita bloqueada, o cadastro de produtos passa a ser feito pelo
> console do Firebase ou pelo futuro painel administrativo (via Admin SDK, que ignora
> estas regras). O app nunca escreve no catálogo.

## Atualização de ambiente e dependências (2026-08-03)

O projeto estava parado desde ~2021, em um Flutter/Dart pré-null-safety-obrigatório e
com Firebase/Gradle muito desatualizados — não compilava mais com o Flutter atual. Foi
feita uma modernização completa do toolchain e das libs para o app voltar a rodar:

- **Flutter:** atualizado para 3.24.5 (stable) / Dart 3.5.4
- **Android:** Gradle 6.7 → 8.3, AGP 4.1.0 → 8.1.0, Kotlin 1.6.10 → 1.8.22, `compileSdk`/`targetSdk` passados a usar os valores do próprio Flutter, `minSdk` elevado para 23 (exigido pelo `firebase-auth` atual)
- **Firebase:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` atualizados das versões `0.x` (2020) para as versões atuais `^3.x`/`^5.x`/`^12.x`
- `flutter analyze` limpo (0 erros)
- `google-services.json` original preservado (projeto Firebase `bemestardata`, `applicationId` mantido como `br.com.claudiodev.bemestarcem`)

### Troca de template de UI (2026-08-03)

O visual do app foi totalmente substituído pelo template `flutter_ecommerce_template`
("Shope"), adaptado para a Bem Estar Cem:

- Cor de marca trocada de amarelo/laranja para uma paleta **azul** (`app_properties.dart`
  e todos os pontos que usavam laranja diretamente)
- Removida toda referência visual à marca original ("Shope"): logo, texto "Powered by
  int2.io", ícones de marca
- App **traduzido integralmente para português (pt-BR)**: todas as ~50 telas, textos de
  botão, mensagens, categorias, produtos de exemplo e formatos de data/moeda (`R$`,
  datas via `intl` com locale `pt_BR`)
- Fluxo de abertura corrigido: splash → banner de apresentação → login (antes o app
  abria direto na tela de login)
- Dependências do template (`card_swiper`, `flutter_staggered_grid_view`,
  `flutter_rating_bar`, `flutter_svg`, `numberpicker` etc.) adicionadas ao
  `pubspec.yaml`, convivendo com as dependências de Firebase já existentes

### Integração com Firebase (2026-08-03)

Depois da troca de template, a lógica de Firebase do protótipo anterior foi religada e
modernizada nas telas novas:

- `UserManager` reescrito: agora captura `FirebaseAuthException` (o código antigo
  capturava `PlatformException` com códigos no formato antigo `ERROR_*`, que o Firebase
  atual não emite mais — as mensagens de erro nunca apareceriam corretamente)
- `ProductManager` carrega o catálogo de `products` com estados de carregando/erro/vazio
- `CartManager` novo: carrinho persistido em `users/{uid}/cart`, recarregado a cada
  troca de usuário via `ChangeNotifierProxyProvider2`
- Preços formatados em Real com `intl` (`NumberFormat.currency` pt-BR) — o template
  exibia dólar e tinha centavos fixos ".58" colados no preço
- Widget `ProductImage` novo: escolhe entre `Image.asset` (produtos de exemplo) e
  `Image.network` (produtos do Firestore), com fallback quando a imagem falha
- Telas removidas por não fazerem parte do negócio: carteira digital, enviar/solicitar
  dinheiro, histórico de pagamentos, e a tela de código OTP (o Firebase Auth com
  e-mail/senha usa link de redefinição por e-mail, não código SMS)
- Removidos também o `api_service.dart` e os models da API fake (randomuser.me) que só
  serviam às telas de carteira

O app foi validado rodando via `flutter run` diretamente em um aparelho físico Android
conectado por Wi-Fi (wireless debugging/adb), sem necessidade de emulador gráfico.

## Como rodar localmente

Pré-requisitos: Flutter 3.24+ e Android SDK configurados (`flutter doctor` sem
pendências em "Flutter" e "Android toolchain").

```bash
flutter pub get
flutter run            # com um emulador ou celular conectado (USB ou wireless debugging)
```

Para gerar um APK de debug para instalar manualmente em um celular:

```bash
flutter build apk --debug
# saída em build/app/outputs/flutter-apk/app-debug.apk
```

### Rodar em celular físico via Wi-Fi (sem cabo)

1. No celular: Configurações → Sobre o telefone → tocar 7x em "Número da versão" para
   ativar Opções do desenvolvedor.
2. Em Opções do desenvolvedor, ativar **Depuração sem fio**.
3. Tocar em "Parear dispositivo com código de pareamento" e anotar IP:porta + código.
4. No computador:
   ```bash
   adb pair <ip>:<porta-pareamento> <código>
   adb connect <ip>:<porta-conexão>
   flutter run -d <ip>:<porta-conexão>
   ```

## Estrutura do projeto

```
lib/
├── main.dart                  # Firebase.initializeApp, providers, locale pt-BR, tema azul
├── app_properties.dart        # Cores de marca, gradiente do botão principal, sombra padrão
├── custom_background.dart     # Pintura de fundo customizada
├── common/product_image.dart  # Imagem de produto (asset do template ou URL do Firestore)
├── helpers/                   # Validadores, mensagens de erro do Firebase, formato de preço
├── models/                    # AppUser, UserManager, Product, ProductManager,
│                              # CartProduct, CartManager, Category
└── screens/
    ├── splash_page.dart, intro_page.dart   # Abertura (splash + banner)
    ├── auth/                                # Login, cadastro, recuperação de senha
    ├── main/                                 # Home, abas, navegação inferior
    ├── category/, search_page.dart            # Categorias e busca
    ├── product/                                # Catálogo, detalhe, opções, avaliações
    ├── rating/                                  # Avaliação de produto/pedido
    ├── shop/, payment/, select_card_page.dart    # Carrinho, checkout, pagamento
    ├── address/                                   # Endereço de entrega
    ├── tracking_page.dart                          # Acompanhamento de entrega
    └── settings/, profile_page.dart, faq_page.dart,
        notifications_page.dart                      # Perfil e configurações
```

> Nota: a estrutura é "por feature de tela" dentro de `screens/`, com o estado em
> `models/` via `provider` (ChangeNotifier). Não segue Clean Architecture
> (data/domain/presentation) — conforme o checkout e os pedidos crescerem, vale avaliar
> a recomendação de arquitetura da empresa em
> `.claude/skills/techindev-co/agents/mobile/agent-mobile.md`.

## Próximos passos recomendados

1. ✅ ~~Publicar as regras do Firestore~~ — **concluído e validado** (ver tabela acima).
   O banco estava totalmente aberto e hoje está protegido.
2. **Substituir os produtos de demonstração** pelos produtos e fotos reais da loja —
   os 10 atuais usam imagens do Unsplash apenas para demonstração
3. Validar com o cliente as perguntas abertas do documento de requisitos (gateway de
   pagamento, fornecedores-piloto, transportadora, prazo/orçamento)
4. Implementar o fechamento de pedido (gravar `orders` no Firestore ao finalizar a compra)
5. Integrar o gateway de pagamento (cartão + Pix) escolhido
6. Ligar o acompanhamento de entrega a pedidos reais
7. Criar o painel administrativo para cadastro de produtos e gestão de pedidos
