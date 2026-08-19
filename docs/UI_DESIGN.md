# Auditoria de UI/UX e Proposta de Redesenho — App Bem Estar Cem

**Data:** 2026-08-04 | **Versão:** 1.0 | **Responsável:** Agente de UI/UX (Techindev)
**Stack:** Flutter 3.24.5 · Material 3 · pt-BR · Firebase
**Escopo:** telas fora do lote em refatoração pelo agente principal (`welcome_back_page`,
`main/*`, `product/product_page`, `product/view_product_page`, `product/components/product_card`,
`product_display`, `product_options`, `shop/components/shop_item_list`).

> **Legenda de esforço:** **P** = até ~2 h · **M** = ~meio dia · **G** = 1–2 dias.

---

## 1. Diagnóstico geral

O app é um fork do template `flutter_ecommerce_template` (2019), traduzido para pt-BR e
com a cor amarela trocada por azul — mas **apenas nos valores das constantes, não na
estrutura visual**. O resultado é um app que tecnicamente roda em Material 3
(Flutter 3.24 liga `useMaterial3` por padrão), mas que não usa **nenhum** componente M3:

| Evidência | Situação |
|---|---|
| `FilledButton` / `ElevatedButton` / `OutlinedButton` no projeto | **0 ocorrências** |
| Botões desenhados à mão com `InkWell` + `Container(gradient: mainButton)` | **12 cópias** (`app_properties.dart:9`) |
| `Card` usado de fato | 2 telas (`view_product_page`, `add_address_page`) |
| `AppBar(backgroundColor: Colors.transparent, elevation: 0)` copiado | **18 ocorrências** |
| `Image.asset('assets/icons/...')` onde caberia `Icons.*` | **16 ocorrências** + 4 `SvgPicture` |
| `ThemeData` central (`main.dart:37-42`) | 6 linhas, sem `ColorScheme`, sem `textTheme`, sem componentes |

### 1.1 Problemas transversais (resolver **antes** das telas)

| # | Problema | Arquivo:linha | Impacto |
|---|---|---|---|
| T-1 | `canvasColor: Colors.transparent` — hack de Flutter 1.x que deixa `Dropdown`, `Drawer` e menus **sem fundo**. É a causa do `Container(color: Colors.white)` manual dentro do `DropdownMenuItem` em `tracking_page.dart:81`. | `main.dart:39` | Alto |
| T-2 | `locale: const Locale('pt','BR')` **sem** `localizationsDelegates` nem `supportedLocales`. Todo texto interno do Material (tooltips, `showDatePicker`, "CANCEL"/"OK", `TextField` context menu) sai **em inglês**. Falta `flutter_localizations` no `pubspec`. | `main.dart:36` | Alto |
| T-3 | Fonte Montserrat declarada só no peso **Regular** (`pubspec.yaml:86-88`), mas o app usa `FontWeight.bold`/`w600` em ~200 pontos → **negrito sintético** (faux bold), renderização suja no Android. `NunitoSans-Regular` está declarada e nunca é usada. | `pubspec.yaml:85-91` | Alto |
| T-4 | Paleta em constantes soltas com nomes mentirosos: `yellow`, `mediumYellow`, `darkYellow`, `transparentYellow` — todas azuis. Ninguém que entrar no projeto vai entender. | `app_properties.dart:3-6` | Médio |
| T-5 | `mainButton` (gradiente de 3 azuis) + `boxShadow` fixa: assinatura visual de 2019. Sem estado `disabled`, sem ripple real, sem `focus`, sem semântica de botão para leitores de tela. | `app_properties.dart:9-17` | Alto |
| T-6 | `assets/background.jpg` é na verdade um **PNG 375×812** (mockup de tela de celular) usado como: wallpaper de 3 telas, **foto de avatar** em 3 lugares e imagem de cartão. Em `CircleAvatar` ele é cortado no centro → mancha ilegível. | vários | Alto |
| T-7 | Sem `darkTheme` / `themeMode`. Em aparelho no modo escuro o app fica branco puro com texto preto forçado (`darkGrey` hardcoded). | `main.dart:37` | Médio |
| T-8 | `screenAwareSize()` (escala manual por altura de tela) — substituível por `MediaQuery.textScaler` + layout flexível. | `app_properties.dart:19-22` | Baixo |

---

## 2. Auditoria tela a tela

### 2.1 `lib/screens/profile_page.dart` — Perfil

**(a) O que está datado/quebrado**
- `Scaffold` **sem `AppBar`**; o espaço é simulado com `padding: top: kToolbarHeight` (L20) → sem título, sem elevação ao rolar, sem `SafeArea` correto em aparelhos com notch.
- `backgroundColor: Color(0xffF9F9F9)` hardcoded (L14) em vez de `colorScheme.surface`.
- `CircleAvatar(backgroundImage: AssetImage('assets/background.jpg'))` (L23-26) → wallpaper 375×812 recortado em círculo de 96 px. **Imagem desproporcional.**
- "Card" de atalhos é um `Container` com `boxShadow` **azul translúcido** (`transparentYellow`, L53) e `height: 150` fixa (L58) → brilho azulado datado; risco de overflow com `textScaler` ≥ 1.3.
- Três `IconButton(icon: Image.asset(...))` (L67, L81, L96) com assets de tamanhos diferentes — `truck.png` 46×46, `card.png` 33×33, `contact_us.png` 33×33 → **ícones opticamente desalinhados na mesma linha**.
- `settings_icon.png` é **100×100** forçado em `width: 30` (L111), enquanto `support.png` e `faq.png` são 24×24 sem restrição (L120, L130) → três tamanhos visuais diferentes na mesma lista.
- Tiles mortos: "Suporte" (`onPressed: () {}`, L96) e "Ajuda e Suporte" (sem `onTap`, L117-125).
- `Icon(Icons.chevron_right, color: yellow)` (L112, L122, L131) → chevron colorido polui; M3 usa `onSurfaceVariant`.
- `TextStyle` inline (L33, L37) em vez de `textTheme`.

**(b) Proposta**
- `Scaffold` + `CustomScrollView` com **`SliverAppBar.large`** (título "Meu perfil", ação `IconButton(Icons.settings_outlined)`).
- Cabeçalho: `CircleAvatar(radius: 44, foregroundImage: NetworkImage(user.photoUrl), child: Text(iniciais))` — fallback por iniciais, **nunca** o wallpaper. Nome em `titleLarge`, e-mail em `bodyMedium` + `onSurfaceVariant`.
- Atalhos: `Card(margin: …)` contendo `Row` de 3 `Expanded(child: InkWell(borderRadius: …, child: Column(Icon, SizedBox(8), Text)))` — sem altura fixa, com `Icon(size: 28)`:
  `Icons.local_shipping_outlined` (Envios) · `Icons.credit_card_outlined` (Pagamento) · `Icons.support_agent` (Suporte).
- Menu: `Card(clipBehavior: Clip.antiAlias)` envolvendo `Column` de `ListTile` com `leading: Icon(...)`, `trailing: Icon(Icons.chevron_right)` (cor padrão) e `Divider(height: 1, indent: 56)` entre eles.
  Mapa de ícones: Configurações → `Icons.settings_outlined`; Ajuda e Suporte → `Icons.headset_mic_outlined`; Perguntas Frequentes → `Icons.help_outline`.
- Adicionar tiles reais que faltam ao produto: **Meus pedidos** (`Icons.receipt_long_outlined`), **Endereços** (`Icons.location_on_outlined`), **Favoritos** (`Icons.favorite_border`) — cobrem RF-011, RF-008 e RF-018.
- Remover ou desabilitar visualmente (`enabled: false`) qualquer tile sem destino.

**(c) Esforço: M**

---

### 2.2 `lib/screens/settings/settings_page.dart` — Configurações

**(a)**
- `CustomPaint(painter: MainBackground())` (L17-18) pinta uma **faixa azul translúcida no terço direito da tela** (`custom_background.dart:13-14`) — resíduo decorativo do template, sem função. Depende de T-1 para "funcionar".
- `AppBar` transparente + `elevation: 0` + `iconTheme` preto + título com cor manual (L20-30) — o padrão copiado 18×.
- Títulos de seção "Geral" (L44-50) e "Conta" (L83-89) como `Text` cru com `fontSize: 18` hardcoded.
- 7 `Image.asset` de ícones 19×19 (L54, 60, 66, 72, 78, 93, 99) → menores que o padrão M3 (24 dp), lista visualmente "rala".
- "Sobre Nós" com `onTap: (){}` (L79) → morto.
- **"Sair" tem exatamente o mesmo peso visual de "Idioma"** e executa `signOut()` + `pushAndRemoveUntil` **sem confirmação** (L100-105).
- "Idioma" e "Alterar País" levam a telas que não fazem nada em um app 100 % pt-BR.
- `LayoutBuilder` + `ConstrainedBox(minHeight)` + `SingleChildScrollView` (L33-37) para uma lista → complexidade desnecessária.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Configurações')))` — sem `CustomPaint`, sem cores manuais (herda do tema).
- `ListView` com `ListTile` agrupados em `Card` por seção, e cabeçalhos como `Padding + Text(style: textTheme.titleSmall, color: colorScheme.primary)`.
- Ícones nativos: `Icons.notifications_outlined`, `Icons.gavel`, `Icons.info_outline`, `Icons.lock_outline`, `Icons.logout`.
- "Sair" isolado no fim, em `Card` próprio, com `ListTile(iconColor: colorScheme.error, textColor: colorScheme.error)` e `showDialog<bool>` de confirmação (`AlertDialog` + `TextButton('Cancelar')` / `FilledButton.tonal('Sair')`).
- **Remover** "Idioma" e "Alterar País" do menu (e as duas telas) enquanto o app for mono-idioma; se ficarem, virar `ListTile(subtitle: Text(valorAtual))`.
- Adicionar `Text('Versão 1.0.0', style: bodySmall)` centralizado no rodapé.

**(c)** **P**

---

### 2.3 `lib/screens/settings/change_language_page.dart` e `change_country.dart`

**(a)**
- Os dois arquivos são **cópia carbono** um do outro (87 linhas cada, muda só a lista de strings). Em `change_language_page.dart:6,9` a classe de estado se chama `_ChangeCountryPageState` — copy-paste não revisado.
- **Título duplicado**: `AppBar` diz "Configurações" (L34-37) e logo abaixo há um `Text` "Idioma"/"Alterar País" (L47-56).
- Seleção indicada por `Icon(Icons.check_circle, size: 16, color: yellow)` (L70-76) — 16 px é minúsculo; `SizedBox()` como estado não-selecionado faz a linha "pular".
- `currentCountry = ''` (L23) → **nada selecionado ao abrir**; a escolha não persiste em lugar nenhum.
- Lista de países (China, Bengala, Romênia…) e idiomas totalmente irrelevante para uma loja de móveis brasileira.

**(b)**
- **Recomendação primária: excluir as duas telas.** Não há requisito de i18n em `REQUISITOS.md`.
- Se mantidas: um único widget genérico `SelectionListPage({title, options, selected, onChanged})` usando `RadioListTile<String>` dentro de `ListView.builder`, `AppBar(title: Text(title))` (sem título duplicado) e persistência em `SharedPreferences`.

**(c)** **P** (excluir) / **P** (unificar)

---

### 2.4 `lib/screens/settings/change_password_page.dart` — Alterar senha

**(a)**
- 🔴 **Bug de segurança/usabilidade:** os três campos de senha **não têm `obscureText: true`** (L93, L114, L135) — a senha aparece em texto claro na tela.
- Campos são `Container` + `TextField(border: InputBorder.none)` (L86-98, 107-119, 128-140): sem `labelText`, sem estado de erro, sem `Form`, sem `TextEditingController`, sem validação, sem `textInputAction`.
- Botão gradiente de **80 px de altura** e `width / 1.5` (L16-40) com `onTap: () {}` → **não faz nada**.
- Título duplicado ("Configurações" na AppBar + "Alterar Senha" no corpo, L71-77).
- Rótulos redundantes acima de cada campo ("Digite sua senha atual" + hint "Senha atual") — em M3 o `labelText` flutuante já cobre isso.
- `bottomPadding != 20 ? 20 : bottomPadding` (L148) — heurística sem sentido.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Alterar senha')))`.
- `Form` + 3 `TextFormField` com `obscureText`, `decoration: InputDecoration(labelText: …, filled: true, prefixIcon: Icon(Icons.lock_outline), suffixIcon: IconButton(Icons.visibility_outlined/visibility_off_outlined))` e `validator` reaproveitando `helpers/validators.dart`.
- Botão: `FilledButton(onPressed: …, child: Text('Confirmar alteração'))` dentro de
  `bottomNavigationBar: Padding(padding: EdgeInsets.all(16) + viewInsets, child: SizedBox(width: double.infinity, height: 52, child: FilledButton(...)))` — largura total, altura M3, respeita o teclado.
- Ligar em `UserManager` (o `FirebaseAuth.updatePassword` já é viável) + `SnackBar` de sucesso/erro.

**(c)** **M**

---

### 2.5 `lib/screens/settings/legal_about_page.dart` — Jurídico e Sobre

**(a)**
- **Os 5 `ListTile` não têm `onTap`** (L48-67) → tela 100 % decorativa.
- Título duplicado (AppBar "Configurações" + `Text` "Jurídico e Sobre", L37-43).
- `import 'dart:io'` (L1) e `package:flutter/cupertino.dart` (L4) não usados — `dart:io` **quebra o build web**.
- `Icon(Icons.chevron_right)` sem `leading`, lista sem hierarquia.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Jurídico e sobre')))` + `ListView` de `ListTile` com `leading` (`Icons.description_outlined`, `Icons.privacy_tip_outlined`, `Icons.workspace_premium_outlined`, `Icons.storefront_outlined`, `Icons.assignment_return_outlined`) e `onTap` abrindo uma `LegalDocumentPage(title, markdownAsset)` genérica ou `url_launcher`.
- Rodapé com `AboutListTile` nativo (`applicationName`, `applicationVersion`, `applicationLegalese`) — resolve "Sobre Nós" de graça.
- Remover os dois imports mortos.

**(c)** **P**

---

### 2.6 `lib/screens/settings/notifications_settings_page.dart` — Notificações

**(a)**
- 🔴 **Bug funcional:** `platformSwitch(bool val)` (L20-42) recebe o bool **por valor** e faz `setState(() { val = value; })` — atribui ao parâmetro local. **Nenhum switch da tela liga/desliga de verdade.** No ramo iOS ainda há `value: true` fixo (L26).
- `Platform.isIOS` (L21) exige `dart:io` → **quebra em Flutter Web**; e é desnecessário: em M3 o `Switch` já tem forma adequada nas duas plataformas.
- `activeColor: yellow` (L29, L39) — API legada; M3 usa `WidgetStateProperty` via `SwitchThemeData`.
- `ListTile(trailing: Switch(...))` em vez de `SwitchListTile` → a linha inteira não é tocável.
- Título duplicado; sem subtítulos explicando cada notificação; sem persistência (RF-013).

**(b)**
- `Map<String,bool> prefs` no state (ou `NotificationSettingsManager` no Provider) + `SwitchListTile.adaptive` gerado por `ListView`:
  `SwitchListTile(value: prefs[k]!, onChanged: (v) => setState(() => prefs[k] = v), title: Text(...), subtitle: Text(...), secondary: Icon(...))`.
- Agrupar em duas seções (`Card`): **Pedidos** (Meus pedidos, Lembretes, Atualizações) e **Marketing** (Novas ofertas, Comentários e avaliações).
- Persistir em `SharedPreferences` + tópicos FCM.
- Remover `dart:io` e o `platformSwitch`.

**(c)** **P**

---

### 2.7 `lib/screens/shop/check_out_page.dart` — Finalizar compra

**(a)**
- Botão "Finalizar Compra" (L23-48): gradiente, 80 px, `width/1.5`, `InkWell` sem `Material` acima → **sem ripple**, sem estado desabilitado com carrinho vazio, sem `Semantics` de botão.
- `IconButton(icon: Image.asset('assets/icons/denied_wallet.png'))` (L58) — asset **28×23** (não quadrado) → ícone torto na AppBar. Deveria ser `Icons.account_balance_wallet_outlined`.
- Barra de subtotal: `Container(height: 48, color: yellow)` full-bleed (L78-101) com dois `Text` sem `Flexible` → **risco de overflow** quando `totalItems` + preço formatado forem longos (ex.: "12 itens · R$ 12.345,67") em telas de 320 dp ou com `textScaler` alto.
- `SizedBox(height: 300)` fixo para a lista do carrinho (L102-118) → em tela pequena come metade da viewport; com 1 item sobra buraco.
- Carrossel de cartões: `Swiper(itemCount: 2)` (L131-141) com `CreditCard()` **hardcoded** → dois cartões falsos idênticos. Depende de `card_swiper`, que pode sair com o resto.
- **Faltam frete, impostos, total e endereço** — o botão vai direto para `AddAddressPage`, invertendo a ordem natural do checkout.
- `class Scroll extends CustomPainter` (L162-196) é **código morto** com `// TODO: implement paint`.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Finalizar compra')), body: CustomScrollView(slivers: [...]), bottomNavigationBar: …)`.
- Resumo do topo → `Card` (não faixa colorida) com `ListTile(title: Text('Subtotal'), trailing: Text(formatPrice(...)))`; envolver os textos em `Flexible` + `overflow: TextOverflow.ellipsis`.
- Lista de itens: `SliverList.builder` (sem altura fixa) com `ShopItemList` (já em refatoração pelo agente principal).
- Pagamento: `RadioListTile`/`SegmentedButton` para **Cartão / Pix** (RF-009, RF-010) + `Card` de cartão salvo com `ListTile(leading: Icon(Icons.credit_card), title: Text('•••• 4951'), trailing: Icon(Icons.check_circle))`. Eliminar o `Swiper`.
- Bloco de totais: `Card` + `Column` de `Row`s (Subtotal, Frete, Descontos, **Total** em `titleLarge`) — tudo via `formatPrice`.
- CTA fixo em `bottomNavigationBar`: `SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(icon: Icon(Icons.lock_outline), label: Text('Continuar')))`, `onPressed: null` quando o carrinho está vazio.
- Estado vazio (já existe em L105) → promover a `Center(child: Column(Icon(Icons.shopping_cart_outlined, size: 64), Text('Seu carrinho está vazio'), FilledButton.tonal('Ver produtos')))`.
- Apagar `class Scroll`.

**(c)** **G**

---

### 2.8 `lib/screens/shop/components/credit_card.dart` — Cartão (widget)

**(a)**
- `Colors.deepPurple[700]` (L11) — **roxo**, fora da paleta azul da marca.
- Dados falsos em produção: `'xxxx - xxxx - xxxx - 4951'` (L28) e **`'GEORGE W BUSH'`** (L40).
- O "chip" do cartão é um `Container(25×40, color: Colors.white)` (L22-26) → retângulo branco cru.
- `height: 200, width: 250` fixos com 4 `Text` em `spaceAround` → **overflow** com `textScaler` ≥ 1.3.
- Nenhum parâmetro: o widget não recebe modelo de cartão.

**(b)**
- `class CreditCardTile extends StatelessWidget { final SavedCard card; final bool selected; final VoidCallback onTap; }`.
- Render: `Card(color: colorScheme.primaryContainer, clipBehavior: Clip.antiAlias, child: InkWell(onTap: …, child: Padding(...)))` com `AspectRatio(aspectRatio: 1.586)` (proporção real de cartão) em vez de 200×250 fixos.
- Bandeira → `Icon(Icons.credit_card)` ou logo em SVG da bandeira; selecionado → `Icon(Icons.check_circle)` no canto.
- Tipografia via `textTheme` e cores via `onPrimaryContainer`.

**(c)** **P**

---

### 2.9 `lib/screens/payment/payment_page.dart` — Cadastro de cartão

**(a)**
- Sem `AppBar`: `margin: top: kToolbarHeight` (L91) + `Row` manual com título e `CloseButton()` (L95-107).
- Pré-visualização do cartão: `Container(height: 200, color: active)` onde `active = Colors.red` por padrão (L13) → **cartão vermelho** na abertura, colidindo com a semântica de erro do M3.
- Seletor de "cor do cartão" com 5 cores arbitrárias (L165-191) — enfeite do template, sem valor para o usuário.
- Formulário: `Container(height: 250)` fixo (L192-201) com `Column(mainAxisAlignment: spaceAround)` contendo 3 linhas de `Container` + `TextField(border: InputBorder.none)` → **risco alto de overflow** assim que aparecer texto de erro ou o teclado; sem `labelText`, sem validação, sem máscara.
- CVC sem `LengthLimitingTextInputFormatter` (L285-289); mês/ano sem `keyboardType: TextInputType.number`; número do cartão sem agrupamento visual (a formatação `convertCardNumber` só é aplicada na pré-visualização, L134).
- 🔴 Botão "Adicionar Cartão" (L51-76) **sem `onTap`** — comentado nas linhas 52-53. A tela não salva nada.
- Conflito com **RF-009** (tokenização, "sem armazenar dados do cartão no app"): a tela coleta PAN/CVC em texto puro no state.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Adicionar cartão'), leading: CloseButton()))`.
- Pré-visualização com o `CreditCardTile` da §2.8 (`colorScheme.primaryContainer`), atualizada via `ValueListenableBuilder` — **remover o seletor de cores**.
- `Form(key:)` + `ListView` de `TextFormField`:
  - Número → `keyboardType: number`, `inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), _CardNumberFormatter()]`, `prefixIcon: Icon(Icons.credit_card)`.
  - Validade → um único campo `MM/AA` com formatter; CVV → `obscureText`, `maxLength: 4`, `suffixIcon: IconButton(Icons.help_outline)` explicando onde fica.
  - Titular → `textCapitalization: TextCapitalization.characters`.
  - Todos com `decoration: InputDecoration(labelText:…, filled: true)` (herdado de `inputDecorationTheme`).
- `CheckboxListTile('Salvar este cartão')`, e CTA `FilledButton` de largura total em `bottomNavigationBar`.
- Trocar o armazenamento por tokenização no gateway (tarefa de backend, mas a UI deve indicar: `Row(Icon(Icons.lock_outline), Text('Seus dados são criptografados'))`).

**(c)** **G**

---

### 2.10 `lib/screens/payment/promo_item.dart` — Item promocional

**(a)**
- Widget 100 % **mock**: nome (L39), preço `'R\$58.24'` (L56) e URL Unsplash (L134) hardcoded. O preço usa **ponto decimal**, não o padrão pt-BR (`R$ 58,24`) — existe `helpers/formatters.dart#formatPrice` e não é usado.
- `Stack(height: 280)` com filho `Container(height: 250)` em `Alignment(0, 0.8)` mais `Positioned(top: 5)` (L10-17, L130) → sobreposição frágil calibrada a olho; qualquer mudança de altura quebra.
- `Container(width: 200)` fixo dentro de um `Row` (L32-34) → **overflow em telas < 360 dp**.
- `borderRadius` só nos cantos inferiores (L23-25) → o card parece cortado.
- **30 linhas de código comentado** (`ListWheelScrollView`, L69-99) com `//TODO`.
- `ColorOption(Colors.red)` (L54) — bolinha vermelha sem função em uma loja de móveis.

**(b)**
- Substituir por um `Card` comum: `ListTile(leading: ClipRRect(borderRadius: 8, child: ProductImage(...)), title: Text(product.name), subtitle: Text(formatPrice(product.price)), trailing: …)`.
- Cupom vira bloco próprio: `Card` + `Row(Expanded(TextFormField(labelText: 'Cupom de desconto', prefixIcon: Icon(Icons.local_offer_outlined))), SizedBox(8), FilledButton.tonal('Aplicar'))`.
- Cupom aplicado → `Chip(avatar: Icon(Icons.check), label: Text('BEMVINDO10'), onDeleted: …)`.
- Receber `Product` por parâmetro; apagar o código comentado.

**(c)** **M**

---

### 2.11 `lib/screens/payment/unpaid_page.dart` — Pagamento pendente

**(a)**
- 🔴 Botão "Pagar Agora" (L13-38) **sem `onTap`** (comentado L14-15) → tela sem saída.
- Todos os valores hardcoded e **sem formatação pt-BR**: `'74.68'`, `'1.25'`, `'76.93'`, `'-10.93'`, `'R\$ 66.93'` (L87-113).
- `Container` de totais com `borderRadius` só embaixo (L79-81) — depende visualmente do `PromoItem` acima; isolado parece quebrado.
- `ListTile(trailing: Text(valor))` para valores monetários → alinhamento inconsistente e `trailing` não é a semântica certa.
- Sem `AppBar`: título + `CloseButton()` manuais (L53-70).
- Título **"Não Pago"** — tradução literal ruim; o termo do domínio é "Pagamento pendente".
- `Material` como raiz em vez de `Scaffold` → sem `ScaffoldMessenger` para `SnackBar`.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Pagamento pendente'), leading: CloseButton()))`.
- `Chip(avatar: Icon(Icons.schedule), label: Text('Aguardando pagamento'), backgroundColor: colorScheme.errorContainer)` no topo — status explícito.
- Resumo: `Card` + `Column` de `Row(mainAxisAlignment: spaceBetween)` com `Text(label, style: bodyMedium)` / `Text(formatPrice(v), style: bodyMedium)`; `Divider()`; linha **Total** em `titleLarge` + `colorScheme.primary`.
- CTA: `bottomNavigationBar` com `FilledButton.icon(icon: Icon(Icons.pix)/Icon(Icons.credit_card), label: Text('Pagar agora'))` + `OutlinedButton('Cancelar pedido')`.
- Ligar em `CartManager`/pedido real; todos os valores por `formatPrice`.

**(c)** **M**

---

### 2.12 `lib/screens/tracking_page.dart` — Rastreio

**(a)**
- Fundo: `DecorationImage(AssetImage('assets/Group 444.png'), fit: BoxFit.contain)` (L36-38) — asset decorativo **397×663** do template, esticado atrás da tela inteira e depois encoberto por `Colors.white54` (L40) → resultado turvo e fora da marca. **Imagem desproporcional.**
- `leading: SizedBox()` + `actions: [CloseButton()]` (L54-55) → o botão de voltar virou um "X" no canto **direito**; inconsistente com o resto do app.
- `DropdownButton` cru dentro de `Container` branco (L68-102); precisa de `Container(color: Colors.white)` manual em cada item (L81) só por causa de T-1. `maxLines: 2` + `ellipsis` dentro de `Row` → **risco de overflow** com nomes longos ("Guarda-Roupa 2 Portas Madeira"). `semanticsLabel: '...'` (L87) é acessibilidade **errada** — leitor de tela anuncia "reticências".
- `Theme(data: ThemeData(primaryColor: yellow, fontFamily: 'Montserrat'))` (L109-111) → cria um **`ThemeData` inteiro do zero** para a subárvore, descartando `colorScheme`, `textTheme` e tudo mais. Além disso `primaryColor` **não** colore o `Stepper` em M3 (que usa `colorScheme.primary`).
- `ConstrainedBox(maxHeight: constraints.maxHeight - 48)` (L106-108) — o `48` é número mágico que não corresponde à altura real do dropdown → **overflow ou corte** conforme a fonte do sistema.
- Conteúdo de cada `Step` é `Image.asset('assets/icons/truck.png')` (L122-126) repetido — sem informação.
- `locations.firstWhere((loc) => loc.isHere)` (L137) **lança exceção** se nenhum passo estiver marcado como atual (caso "entregue").
- Dados 100 % mock, sem vínculo com pedidos (RF-012).

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Rastreamento')))` — voltar padrão, sem imagem de fundo.
- Seleção de pedido: **`DropdownMenu<Order>`** (M3) com `expandedInsets: EdgeInsets.zero`, `leadingIcon: Icon(Icons.inventory_2_outlined)`, ou `ListTile` + `showModalBottomSheet` se houver muitos pedidos.
- Card do pedido: `Card` + `ListTile(leading: ProductImage, title: nome, subtitle: 'Pedido #1234 · 3 itens')`.
- Linha do tempo: manter `Stepper(type: StepperType.vertical, controlsBuilder: (_, __) => const SizedBox.shrink())` — **sem** o `Theme` local (herda do tema global) — e `Step.content` com `Text(descrição, style: bodySmall)` em vez do PNG do caminhão. Estados via `StepState.complete` / `.editing` / `.indexed`.
- Status atual como `Chip(avatar: Icon(Icons.local_shipping_outlined), label: Text('Em transporte'))`.
- Trocar `firstWhere` por `indexWhere(...)` com fallback (`< 0 ? steps.length - 1 : i`).
- Apagar `assets/Group 444.png`.

**(c)** **G**

---

### 2.13 `lib/screens/category/category_list_page.dart` — Lista de categorias

**(a)**
- 🔴 **Crash em produção.** `categories = Category.all` é uma **`const List`** (`models/category.dart:15`); `initState` faz `searchResults = categories` (L22-23) — mesma referência. No primeiro toque em `onChanged`, `searchResults.clear()` (L74 e L80) roda **sobre a lista const** → `Unsupported operation: Cannot clear an unmodifiable list`. **Digitar na busca quebra a tela.** Correção mínima: `searchResults = List.of(categories)`.
- Sem `Scaffold`/`AppBar`: `Material` + `margin: top: kToolbarHeight` (L28-31) → sem botão voltar, sem título elevado.
- Busca é `Container` + `TextField(border: InputBorder.none)` + `SvgPicture.asset('assets/icons/search_icon.svg')` (L50-64) → deveria ser `SearchBar`/`SearchAnchor` do M3 com `Icons.search`.
- Filtro `O(n)` com `forEach` + lista temporária dentro de `setState` (L66-83) — verboso; sem debounce; sem estado "nenhum resultado".
- Título "Categorias" como `Text` cru com `fontSize: 22` (L40-47).
- `Padding(vertical: 16)` por item (L90-93) → espaçamento dobrado entre cards.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Categorias')), body: …)`.
- Busca: `SearchBar(hintText: 'Buscar categoria', leading: Icon(Icons.search), trailing: [IconButton(Icons.clear)], onChanged: …)` com `elevation: WidgetStatePropertyAll(0)` e `backgroundColor: surfaceContainerHigh`.
- Resultados: **`GridView.count(crossAxisCount: 2)`** de `Card` com `Ink.image` (ver §2.15) — mais denso e mais moderno que a lista animada atual.
- Vazio: `Center(Column(Icon(Icons.search_off, size: 56), Text('Nenhuma categoria encontrada')))`.
- `searchResults = List.of(categories)` + filtro com `where(...).toList()`.

**(c)** **M** (a correção do crash isolada é **P** e deve ser feita já)

---

### 2.14 `lib/screens/category/category_products_page.dart` — Produtos da categoria

**(a)** É a tela mais moderna do lote (já usa `ListView.separated`, `ProductImage`, `formatPrice`), mas:
- `backgroundColor: Color(0xffF9F9F9)` hardcoded (L19).
- `Material` + `InkWell` + `borderRadius` manuais (L34-38) em vez de `Card`.
- `TextStyle` inline (L58-65) em vez de `textTheme`.
- `Icon(Icons.chevron_right, color: yellow)` (L69) — chevron azul.
- `AppBar` com cor de ícone/título manual (L20-25).
- Sem estado de carregamento enquanto `ProductManager` busca; sem contagem de resultados; sem ordenação/filtro (RF-003 pede filtro).
- Thumbnail `72×72` com `BoxFit.cover` — ok, mas sem `loadingBuilder`.

**(b)**
- `Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap:…, child: Row(...)))`; textos via `titleMedium` / `titleSmall`+`primary`.
- `AppBar(title: Text(category))` sem overrides; subtítulo com contagem: `Text('${products.length} produtos', style: bodySmall)`.
- `PopupMenuButton`/`SegmentedButton` de ordenação (menor preço / maior preço / mais recentes).
- `Chip` de "Envio imediato" vs "Sob encomenda" (RF-006).
- Estado de carregamento com `ListView` de `Card` em skeleton (ou `CircularProgressIndicator` centralizado).

**(c)** **P**

---

### 2.15 `lib/screens/category/components/staggered_category_card.dart` — Card de categoria

**(a)**
- `Container` com **`LinearGradient(begin→end)`** por categoria (L49-54) — a assinatura visual mais datada do app (gradiente diagonal saturado, 2019).
- `AnimationController` + `Tween` + `CurvedAnimation(Interval(0.0, 0.3))` (L16-35) escritos à mão para uma simples expansão de 150 → 250 px.
- `Image.network(assetPath, fit: BoxFit.cover)` (L80-85) **sem `width`/`height`** dentro de um `Container` cuja altura é animada → a imagem é espremida na altura da animação e a largura fica indefinida em `Column(crossAxisAlignment: end)` → **proporção quebrada durante toda a animação**; sem `loadingBuilder`, `errorBuilder` retorna `SizedBox()` vazio (buraco silencioso).
- "Ver mais" é `GestureDetector` + `Container` branco arredondado (L87-100) — **não é botão**: sem ripple, sem foco, sem semântica.
- `var timeDilation = 10.0;` (L168) — variável local **não usada**, resquício do Flutter Gallery.
- Nome da classe `StaggeredCardCard` (L117) — typo.
- **Densidade ruim:** colapsado (150 px) mostra só o título; a imagem do produto só aparece depois de um toque, e é preciso um segundo toque para entrar.
- Sem `dispose()` do `AnimationController` → **vazamento** ao sair da tela.

**(b)**
- Substituir todo o arquivo por um `CategoryCard` simples e estático:
  ```
  Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onViewMore,
      child: Stack(fit: StackFit.expand, children: [
        Ink.image(image: NetworkImage(url), fit: BoxFit.cover),          // proporção preservada
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient( // scrim só para legibilidade
          begin: Alignment.bottomCenter, end: Alignment.center,
          colors: [Colors.black54, Colors.transparent]))),
        Align(alignment: Alignment.bottomLeft,
          child: Padding(padding: EdgeInsets.all(12),
            child: Text(categoryName, style: textTheme.titleMedium!.copyWith(color: Colors.white)))),
      ]),
    ),
  )
  ```
- Usar dentro de `GridView` com `AspectRatio(16/10)` — sem animação manual, sem controller, sem `dispose`.
- Se a expansão for desejada: `ExpansionTile` dentro de `Card` (`shape`/`collapsedShape` com `borderRadius: 12`) ou `AnimatedSize` — 5 linhas em vez de 190.
- Se o gradiente por categoria for mantido como identidade, usar apenas como **fallback** de imagem, e derivado de `colorScheme` (ex.: `primaryContainer` / `tertiaryContainer`).

**(c)** **M**

---

### 2.16 `lib/screens/search_page.dart` — Busca

**(a)**
- Depende de **`rubber: ^1.0.1`** (`pubspec.yaml:50`) — pacote sem manutenção, só para um bottom sheet arrastável que o Flutter já resolve nativamente.
- 🔴 `dispose()` (L61-63) chama `super.dispose()` e **não descarta** `_controller` (RubberAnimationController) nem `searchController` → **vazamento de memória / ticker órfão**.
- Campo de busca: `Container` com `Border(bottom: BorderSide(color: Colors.blue))` (L93-95) — azul **hardcoded**, não vem da paleta; ícone via `SvgPicture.asset` (L114); botão "Limpar" em `Colors.red` dentro de `suffix` (L118-127).
- 🔴 `searchController.clear(); searchResults.clear();` (L120-122) **fora de `setState`** → a lista não some da tela ao limpar.
- Lista de resultados com fundo `Colors.blue[50]` (L133) — tinta arbitrária; itens são `ListTile(title: Text(nome))` **sem miniatura e sem preço** (L138-145).
- **Sem estado inicial/vazio:** ao abrir, `searchResults` está vazio e aparece só uma área azul em branco.
- Três `ListView` horizontais de 50 px (L190-285) com "chips" feitos à mão (`InkWell` + `Container` + `BorderRadius(45)`), **três blocos de código quase idênticos**; e `selectedPeriod`/`selectedCategory`/`selectedPrice` **nunca são aplicados** aos resultados — filtros decorativos.
- `ListView(physics: NeverScrollableScrollPhysics())` (L165-166) na camada superior → se o conteúdo passar da altura do sheet fica **inacessível** (overflow silencioso).
- Estrutura invertida: `Material` → `SafeArea` → `Scaffold` (L293-298); sem `AppBar`, título e `CloseButton` manuais (L74-90).
- Sem debounce: filtra a cada tecla sobre `allProducts`.

**(b)**
- `Scaffold` + **`SearchAnchor.bar`** (M3) ou `AppBar(title: SearchBar(...))`, com `Icons.search`, `IconButton(Icons.clear)` e `Icons.tune` para abrir filtros.
- Resultados: `ListView.builder` de `Card` + `ListTile(leading: ClipRRect(ProductImage 56×56), title: nome (titleMedium), subtitle: formatPrice, trailing: Icon(Icons.chevron_right))`.
- Estados: inicial → `Text('Buscas recentes')` + `Wrap` de `ActionChip`; vazio → `Icon(Icons.search_off)` + "Nenhum produto encontrado para «x»".
- Filtros: `showModalBottomSheet(showDragHandle: true, isScrollControlled: true)` com `Wrap(spacing: 8, children: [FilterChip(...)])` por seção + `FilledButton('Aplicar')` / `TextButton('Limpar')` — e **aplicar de fato** ao `where` dos resultados.
- Filtros ativos visíveis no topo da lista como `Chip(onDeleted:)`.
- Remover a dependência **`rubber`** do `pubspec`; corrigir `dispose()`; `setState` no "Limpar"; `Timer` de 300 ms para debounce.

**(c)** **G**

---

### 2.17 `lib/screens/notifications_page.dart` — Notificações

**(a)**
- 🔴 **Conteúdo de outro produto.** Os dois primeiros cards são de um app de **pagamentos P2P**: "Sai Sankar Ram **solicitou** R$45,25" (L62-75) e "Sai Sankar Ram **te enviou** R$45,25" (L150-162), com ações "Pagar"/"Aceitar"/"Recusar". Não existe esse conceito em uma loja de móveis.
- `CircleAvatar(backgroundImage: AssetImage('assets/background.jpg'))` (L45-48, L133-136) — de novo o wallpaper 375×812 como foto de pessoa. **Imagem desproporcional.**
- **`fontSize: 10`** em texto de conteúdo (L242, L247, L270, L336) — abaixo do mínimo legível/acessível (12 sp).
- "Botões" são `Row(Icon, Text)` sem `InkWell`/`onTap` (L84-115, L169-204) → parecem clicáveis e não são; alvo de toque nulo.
- Barras azuis full-width fazendo papel de botão (L252-272, L319-338), com texto alinhado à direita em 10 px.
- `SizedBox(110×110)` envolvendo `SizedBox(90×90)` com `Image.network` (L221-235) — caixas fixas aninhadas, sem `loadingBuilder`/`errorBuilder`, URL Unsplash hardcoded.
- `Flexible(child: Column(...))` sem `crossAxisAlignment: start` (L236-249, L303-316) → textos centralizados por acidente; strings longas → **risco de overflow** em telas estreitas.
- 4 cards escritos manualmente, sem modelo, sem `ListView.builder`, sem timestamps, sem distinção lida/não lida, sem estado vazio, sem agrupamento por data.
- `Material` como raiz + `margin: top: kToolbarHeight` (L9-13) → sem `AppBar`.

**(b)**
- **Apagar os dois cards de P2P.** Modelar `AppNotification { type, title, body, imageUrl, createdAt, read, action }` e renderizar com `ListView.builder`.
- `Scaffold(appBar: AppBar(title: Text('Notificações'), actions: [IconButton(Icons.done_all, tooltip: 'Marcar todas como lidas')]))`.
- Item: `Card(clipBehavior: Clip.antiAlias, child: Column(children: [ListTile(leading: CircleAvatar(child: Icon(typeIcon)) /* ou ClipRRect da foto do produto */, title: Text(title, style: titleMedium), subtitle: Text(body, style: bodyMedium), isThreeLine: true, trailing: Text(timeAgo, style: bodySmall)), OverflowBar(alignment: MainAxisAlignment.end, children: [TextButton('Ver pedido'), FilledButton.tonal('Avaliar')])]))`.
- Não lida → `Badge(smallSize: 8)` no `leading` ou `Card(color: colorScheme.primaryContainer)`.
- Ícones por tipo: entrega `Icons.local_shipping_outlined`; avaliação `Icons.star_outline`; promoção `Icons.local_offer_outlined`; pagamento `Icons.payments_outlined`.
- Cabeçalhos de data com `Padding + Text(style: titleSmall)` ("Hoje", "Esta semana").
- Estado vazio: `Icon(Icons.notifications_none, size: 64)` + "Você não tem notificações".
- **Nenhum texto abaixo de 12 sp**; tudo via `textTheme`.

**(c)** **G**

---

### 2.18 `lib/screens/rating/rating_page.dart` — Avaliações do produto

**(a)**
- 🔴 **Imagem estourando a moldura:** `Container(height: 92, width: 92, decoration: BoxDecoration(shape: BoxShape.circle), child: Image.network(...))` (L54-65). Um `Container` com `shape: circle` **não recorta o filho** → a foto aparece como **quadrado sobre o círculo azul**. Precisa de `ClipOval`/`CircleAvatar`.
- Corações (`Icons.favorite`, `#FF8993` rosa) usados como nota de produto (L101-110, L194-205) — semântica de "curtir", não de avaliação; e a cor rosa está fora da paleta.
- `allowHalfRating: true` com `half: SizedBox()` (L109, L204) → meia-estrela renderiza **nada** (buraco na sequência).
- `initialRating: 1` (L98) enquanto o texto ao lado diz **"4.8"** (L86) → incoerência visível.
- `IconButton(icon: Image.asset('assets/icons/comment.png'))` (L25-26) — asset 20×20 na AppBar (padrão é 24).
- `print(value)` em produção (L115, L210).
- Dados mock: URL Unsplash (L64), "Sofá 3 Lugares Veludo" (L70), "4.8" / "de 25 pessoas" (L86, L120), "Billy Holand" / "10h, via iOS" (L169-178), comentário fixo (L215).
- Cards de review são `Container` + `BoxDecoration` (L136-143) em vez de `Card`; "21 curtidas" / "1 comentário" em `fontSize: 10` (L233, L241) e não clicáveis.
- Sem distribuição de notas (barras 5★→1★), sem paginação, sem estado vazio, sem CTA "Avaliar".
- `Column` gigante dentro de `SingleChildScrollView` (L133-253) em vez de `ListView.builder` → todos os reviews construídos de uma vez.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Avaliações'), actions: [IconButton(icon: Icon(Icons.rate_review_outlined), tooltip: 'Escrever avaliação')]))`.
- Cabeçalho: `ListTile(leading: CircleAvatar(radius: 28, foregroundImage: NetworkImage(product.image)), title: Text(product.name))` — recorte correto.
- Resumo: `Row` com `Text('4,8', style: displaySmall)` + `Column(RatingBar com Icons.star (âmbar), Text('25 avaliações', style: bodySmall))` + `Column` de 5 `LinearProgressIndicator` (distribuição por nota).
- Reviews: `ListView.builder` de `Card` + `ListTile(leading: CircleAvatar(child: Text(inicial)), title: Row(nome, Spacer, Text(data, bodySmall)), subtitle: Column(RatingBar readOnly, Text(comentário)))`.
- Ações: `TextButton.icon(Icons.thumb_up_outlined, '21')` e `TextButton.icon(Icons.mode_comment_outlined, '1')`.
- Manter `flutter_rating_bar`, mas com `Icons.star` / `Icons.star_half` / `Icons.star_border` em `Colors.amber` (ou `colorScheme.tertiary`) e `half` **preenchido de verdade**.
- Estado vazio + `FilledButton.tonal('Seja o primeiro a avaliar')`; remover os `print`.

**(c)** **M**

---

### 2.19 `lib/screens/rating/rating_dialog.dart` — Diálogo de avaliação

**(a)**
- 🔴 **Ação errada:** o botão do diálogo de avaliação é "**Pagar Agora**" e navega para `CheckOutPage` (L11-39, L15). Não tem nada a ver com enviar uma avaliação.
- `Dialog(shape: BeveledRectangleBorder(...))` (`rating_page.dart:32`) — cantos **chanfrados**, fora do sistema (M3 usa cantos arredondados de 28).
- Botão gradiente 60 px dentro de um diálogo; sem "Cancelar".
- `TextField(controller: TextEditingController())` **instanciado dentro do `build`** (L94-95) → o controller é recriado a cada rebuild e **o texto digitado se perde**.
- `maxLength: 200` com `border: InputBorder.none` (L97-101) → o contador aparece solto, sem moldura.
- Corações de novo (L77-86) com `allowHalfRating: false` e `half: SizedBox()`.
- Produto hardcoded "Sofá 3 Lugares Veludo" (L64); `Container` + `BoxDecoration` cinza em vez de superfície do tema (L44-46).
- Sem envio: nada é persistido.

**(b)**
- Trocar por **`AlertDialog`** nativo:
  - `icon: Icon(Icons.star_rounded)`, `title: Text('Avalie sua compra')`,
  - `content: Column(mainAxisSize: min, children: [Text('Como foi o «${product.name}»?'), RatingBar(estrelas), TextField(controller: _c, decoration: InputDecoration(labelText: 'Comentário (opcional)', filled: true), maxLines: 3, maxLength: 200)])`,
  - `actions: [TextButton('Agora não'), FilledButton('Enviar avaliação')]`.
- `TextEditingController` em `StatefulWidget` com `dispose()`.
- `FilledButton` desabilitado (`onPressed: null`) enquanto `rating == 0`.
- Após enviar: `Navigator.pop(true)` + `SnackBar('Obrigado pela sua avaliação!')` — nunca navegar para checkout.
- Remover `BeveledRectangleBorder` (o `dialogTheme` do tema já cuida da forma).

**(c)** **P**

---

### 2.20 `lib/screens/auth/register_page.dart` — Cadastro

**(a)**
- 🔴 **O pior layout do app.** `Container(height: 300)` → `Stack` → `Container(height: 220)` contendo um `Form` com **4 `TextFormField`** em `SingleChildScrollView` (L121-216). Quatro campos + mensagens de validação em 220 px → o formulário **rola dentro de uma janelinha**, e com uma mensagem de erro visível os campos ficam parcialmente cortados. **Risco de overflow real.**
- Wallpaper `assets/background.jpg` (**PNG 375×812**) em `BoxFit.cover` (L75-80) + camada `transparentYellow` (L81-83) → em tablet/paisagem a imagem de baixa resolução aparece esticada e borrada.
- Painel branco `Color.fromRGBO(255,255,255,0.8)` com cantos arredondados **só à esquerda** e sangrando para fora da tela à direita (L128-133) — efeito do template.
- Botão gradiente em `Positioned(bottom: 40, left: width/4)` **dentro** do `Stack` de 300 px (L86-119) → sobrepõe o formulário.
- Sem `AppBar`: `Positioned(top: 35, left: 5, child: IconButton(Icons.arrow_back))` (L236-244) — posição fixa que ignora o notch.
- Campos sem `obscureText` alternável, sem `textInputAction`/`FocusNode` encadeados, sem `autofillHints`, sem `prefixIcon`.
- Textos brancos com `shadows: [BoxShadow(...)]` dentro de `TextStyle` (L53-59) — sombra em texto sobre foto: legibilidade baixa e API trocada (`Shadow` vs `BoxShadow`).
- `Spacer(flex: 3/1/2/2)` (L224-230) distribuindo verticalmente → em telas baixas com teclado aberto, colapsa.

**(b)**
- Reconstruir como formulário de tela cheia, **sem foto de fundo**:
  - `Scaffold(appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0))` — voltar nativo.
  - `body: SafeArea(child: ListView(padding: EdgeInsets.all(24), children: [...]))` — rola naturalmente com o teclado.
  - Cabeçalho: logo/marca + `Text('Prazer em te conhecer', style: headlineMedium)` + `Text(subtítulo, style: bodyMedium, color: onSurfaceVariant)`.
  - 4 × `TextFormField(decoration: InputDecoration(labelText:…, filled: true, prefixIcon: Icon(Icons.person_outline / Icons.mail_outline / Icons.lock_outline)), textInputAction: TextInputAction.next, autofillHints: [...])`; senha com `suffixIcon: IconButton(Icons.visibility_outlined)`.
  - `SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: loading ? null : …, child: loading ? SizedBox(20,20,CircularProgressIndicator(strokeWidth: 2)) : Text('Criar conta')))`.
  - `TextButton('Já tenho conta')` abaixo; `CheckboxListTile` de aceite dos termos.
- Se a identidade visual pedir imagem, usar um `SliverAppBar` com `flexibleSpace` de altura controlada — nunca a tela inteira.

**(c)** **M**

---

### 2.21 `lib/screens/auth/forgot_password_page.dart` — Recuperar senha

**(a)**
- Mesmo wallpaper + `transparentYellow` (L71-76) e mesma lógica de `Spacer` (L168-174).
- `Container(height: 210)` → `Stack` → `Container(height: 100, padding: bottom: 30)` para **um único campo** (L122-161) → números mágicos; quando o validator dispara "E-mail inválido", o texto de erro é empurrado para fora dos 100 px → **overflow**.
- Botão gradiente `Positioned(bottom: 40)` sem estado desabilitado visual (L85-120).
- `AppBar` transparente vazia (L79-82) só para ganhar o botão voltar.
- Sucesso comunicado apenas por `SnackBar` verde (L27-30) e `pop()` imediato — o usuário mal lê.

**(b)**
- `Scaffold(appBar: AppBar(), body: SafeArea(child: ListView(padding: 24, children: [...])))`.
- `Icon(Icons.lock_reset, size: 72, color: colorScheme.primary)` no topo (substitui a arte do fundo), `Text(título, headlineSmall)`, `Text(explicação, bodyMedium)`.
- `TextFormField(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline), keyboardType: emailAddress, autofillHints: [AutofillHints.email], filled: true)`.
- `FilledButton` de largura total com spinner interno no estado `loading`.
- Sucesso → trocar o conteúdo por um estado de confirmação (`Icon(Icons.mark_email_read_outlined)` + "Enviamos um link para **{email}**" + `FilledButton.tonal('Voltar ao login')`), em vez de `SnackBar` + `pop`.

**(c)** **P**

---

### 2.22 `lib/screens/address/add_address_page.dart` (+ `address_form.dart`) — Endereço

**(a) `add_address_page.dart`**
- Botão gradiente "Concluir" (L9-35) que pula direto para `SelectCardPage` sem validar nada.
- 🔴 **Cards de tamanhos trocados:** o primeiro é `height: 100, width: 80` (L76-77) e os outros dois `height: 80, width: 100` (L104-105, L134-135) → a linha fica visivelmente desalinhada.
- **`fontSize: 8`** nos rótulos dos cards (L91, L122, L152) — ilegível.
- `Image.asset('assets/icons/address_home.png')` **sem restrição** no primeiro card (L85-87) vs `height: 20` nos outros (L116, L147) → três tamanhos de ícone.
- `Row(spaceBetween)` com larguras fixas 80+100+100 = 280 px + padding 32 = 312 px → **overflow em telas de 320 dp**, e qualquer 4º endereço quebra.
- Endereços hardcoded: "João Silva, São Paulo" (L120), "Trabalho" (L150).

**(a) `address_form.dart`**
- `SizedBox(height: 500)` fixo para o formulário inteiro (L7-8) → **overflow garantido** com o teclado aberto em telas menores.
- 🔴 **Campo duplicado e rotulado errado:** um bloco com label "Bairro" (L40) cujo `hintText` é **"Complemento"** em `fontSize: 24` bold sobre `Colors.blue[100]` (L45-65) — mock de "campo em foco" que ficou permanente — seguido de **outro** campo "Complemento" (L68-78).
- Campo CEP com `Border(bottom: BorderSide(color: Colors.red))` **fixo** (L85) → parece erro permanente.
- Todos os campos são `Container` + `TextField(border: InputBorder.none)`: sem `Form`, sem controllers, sem validators, sem máscara de CEP, sem `keyboardType: number`, sem integração com Firestore.
- `Checkbox` + `Text` soltos em `Row` (L94-102) → só o quadradinho é tocável.

**(b)**
- Seletor de endereço: **`SegmentedButton<AddressType>`** (Casa / Trabalho / Outro) com `Icons.home_outlined`, `Icons.work_outline`, `Icons.place_outlined` — ou `ListView` horizontal de `ChoiceChip`. Endereços salvos → `Card` + `RadioListTile(title: Text(apelido), subtitle: Text(endereçoCompleto), secondary: Icon(...))`.
- Formulário: `Form` + `ListView` (sem altura fixa) de `TextFormField` com `labelText` e `filled: true`, na ordem brasileira: **CEP** (com `inputFormatters` de máscara `00000-000` e busca automática via ViaCEP) → Rua → Número → Complemento → Bairro → Cidade → UF (`DropdownButtonFormField`).
- `CheckboxListTile('Salvar como endereço principal')`.
- CTA em `bottomNavigationBar`: `FilledButton('Salvar endereço')`, largura total, desabilitado enquanto inválido.
- Remover completamente o bloco azul de "Bairro/Complemento" e a borda vermelha do CEP.

**(c)** **G** (as duas juntas)

---

### 2.23 `lib/screens/intro_page.dart` — Onboarding

**(a)**
- `DecorationImage(image: AssetImage('assets/background.png'))` **sem `fit`** (L19-21) → o PNG 374×476 é desenhado no tamanho natural e **repetido/centralizado** conforme a tela; muda de aparência em cada aparelho.
- `Image.asset('assets/firstScreen.png', height: 200, width: 200)` **sem `fit`** (L36-42, L67-73, L98-104) — os assets são **244×195**, **226×244** e **264×238** (nenhum quadrado) forçados em 200×200 → **distorção de proporção nas 3 ilustrações**.
- Indicador de páginas: 3 `Container` circulares hardcoded com `Border.all(color: Colors.black, width: 2)` (L136-162) — borda preta grossa, visual cru, e o número de bolinhas não acompanha o número de páginas.
- 🔴 `Opacity(opacity: 0.0)` no botão "PULAR" na última página (L168-170) → **o botão continua tocável mesmo invisível**. Deve ser `Visibility(visible:)` ou `AnimatedOpacity` + `IgnorePointer`.
- Textos alinhados à **direita** (`TextAlign.right`, `crossAxisAlignment: end`, L34, L47, L57) — incomum em pt-BR e desalinhado dos botões embaixo.
- CTAs em `TextButton` preto negrito e **CAIXA ALTA** ("PULAR", "PRÓXIMO", "COMEÇAR") — hierarquia plana: as três ações têm o mesmo peso.
- `Positioned(bottom: 16)` sem `left`/`right` (L127-130) — depende do `SizedBox(width: MediaQuery…)` interno.
- O onboarding aparece **em todo lançamento** de usuário deslogado (`splash_page.dart:41`) — sem flag "já viu".

**(b)**
- `Scaffold(body: SafeArea(child: Column([Expanded(PageView(...)), _controles])))`; fundo `colorScheme.surface` (sem imagem tiled).
- Cada página: `Column(children: [Expanded(child: Image.asset(..., fit: BoxFit.contain)), Text(título, style: headlineSmall, textAlign: center), Text(descrição, style: bodyLarge, color: onSurfaceVariant, textAlign: center)])` — `fit: BoxFit.contain` resolve a distorção.
- Indicador: `Row(children: List.generate(pages.length, (i) => AnimatedContainer(width: i == index ? 24 : 8, height: 8, decoration: BoxDecoration(color: i == index ? colorScheme.primary : colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)))))` — "pill" moderno, sem borda preta.
- Controles: `Row(children: [TextButton('Pular') envolvido em Visibility, Spacer, FilledButton(index == last ? 'Começar' : 'Próximo')])`.
- Gravar `intro_seen` em `SharedPreferences` e pular na próxima abertura.
- Alinhar os textos ao centro (ou à esquerda), nunca à direita.

**(c)** **M**

---

### 2.24 `lib/screens/splash_page.dart` — Splash

**(a)**
- 🔴 **Animação invertida:** `Tween<double>(begin: 1.0, end: 0.0)` em 2500 ms (L21-26) → o nome da marca **some** e o usuário encara ~1 s de tela azul vazia antes de navegar.
- `setState(() {})` no listener da animação (L24-26) → rebuild da árvore inteira a cada frame; o correto é `FadeTransition`/`AnimatedBuilder`.
- Espera **fixa de 2,5 s** antes de checar o login (L27-29, L38-42), independente de o Firebase já estar pronto → atraso artificial em toda abertura.
- Wallpaper `background.jpg` + `transparentYellow` (L46-50); texto em `darkYellow` (`#1565C0`) sobre overlay azul → **contraste baixo** (falha WCAG AA).
- Sem logotipo — só um `Text('Bem Estar Cem')`.
- `new Scaffold(...)` (L52) — palavra-chave `new` legada.
- Sem splash nativa (`flutter_native_splash`) → flash branco no cold start antes desta tela.

**(b)**
- Fundo sólido `colorScheme.primary` (ou `surface`), **sem foto**.
- `FadeTransition(opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn))` com `begin: 0 → end: 1` (fade **in**), 600 ms, sobre um `Column(Image.asset(logo, height: 96), SizedBox(24), Text('Bem Estar Cem', style: headlineMedium, color: onPrimary))`.
- Navegar assim que `UserManager` sinalizar pronto (`await`/`Future.wait` com um `Future.delayed(600ms)` mínimo), não com timer fixo de 2,5 s.
- `CircularProgressIndicator(color: onPrimary)` discreto no rodapé.
- Adicionar `flutter_native_splash` com a mesma cor de fundo → transição sem flash.

**(c)** **P**

---

### 2.25 `lib/screens/faq_page.dart` — Perguntas frequentes

**(a)**
- 🔴 `AppBar` diz **"Configurações"** (L48) — a tela é aberta a partir do **Perfil**, não das Configurações. Título errado.
- Painel de resposta com `Container(color: Color(0xffFAF1E2))` (L79) — **bege/creme**, sobra literal do template amarelo original; grita no meio de um app azul.
- Títulos das perguntas em **CAIXA ALTA** (L13, L17, L21, L25, L29, L33) e em `Colors.grey[600]` — soa como grito e tem contraste fraco.
- **4 das 6 respostas são o mesmo texto copiado** (L22, L26, L30, L34) — conteúdo claramente não revisado.
- Pergunta sobre "**amostras grátis**" (L17-18) — irrelevante para móveis e eletrodomésticos.
- Título duplicado (AppBar + `Text('Perguntas Frequentes')`, L61-67).
- Classe `Panel` com campo `expanded` (L96) que **nunca é usado**.
- `import 'package:flutter/cupertino.dart'` (L2) não usado.
- `ExpansionTile` sem `shape`, sem separadores → colapsado, tudo vira uma parede cinza.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Perguntas frequentes')))` — título correto e único.
- `ListView.separated` de `Card(clipBehavior: Clip.antiAlias, child: ExpansionTile(shape: RoundedRectangleBorder(borderRadius: 12, side: BorderSide.none), collapsedShape: …, leading: Icon(Icons.help_outline), title: Text(pergunta, style: titleMedium), children: [Padding(EdgeInsets.fromLTRB(16,0,16,16), child: Text(resposta, style: bodyMedium))]))` — painel usa `colorScheme.surfaceContainerLow`, **nunca** `#FAF1E2`.
- Perguntas em **sentence case**; reescrever o conteúdo para o domínio real (prazo de entrega de móveis, montagem, frete, garantia, devolução, Pix/cartão) — remover "amostras grátis" e as 4 respostas duplicadas.
- Opcional: `SearchBar` no topo filtrando as perguntas, e `TextButton.icon(Icons.support_agent, 'Falar com o suporte')` no rodapé.
- Remover import morto e o campo `expanded`.

**(c)** **P** (UI) + revisão de conteúdo com o cliente

---

### 2.26 Extra — `lib/screens/select_card_page.dart` (não listada, mas dentro do fluxo de checkout)

Alcançada por `add_address_page.dart:10-12`. Auditada por estar no caminho crítico da compra.

**(a)**
- `Transform.rotate(angle: math.pi / 2)` sobre um `Container` cujas `width`/`height` são **trocadas de propósito** para compensar a rotação (L32-37) — layout indecifrável e impossível de manter.
- `MediaQuery.size.width / 1.2` e `height / 1.4` como dimensões (L10, L28, L36) — números mágicos.
- Dois retângulos coloridos puramente decorativos (`#A647DD` roxo, `#454ECA` índigo, L65-86) fingindo ser cartões empilhados — **fora da paleta**.
- Cartão principal em `#353A85` (L39) com número **hardcoded** `'4452 - 8645 - 4524 - 2413'` (L57).
- Campo CVV é um `TextField` dentro de `Container(width: 90)` sem label (L134-156).
- Textos em `fontSize: 10` (L124, L128, L163, L172).
- `CircleAvatar(AssetImage('assets/background.jpg'))` (L106-110) de novo como logo da loja.
- Nenhuma seleção real: os "cartões" não são tocáveis, e não há botão de confirmar.

**(b)**
- `Scaffold(appBar: AppBar(title: Text('Selecionar cartão')))` + `ListView` de `CreditCardTile` (§2.8) com `RadioListTile`/`InkWell` de seleção.
- CVV em `AlertDialog` ou campo abaixo do cartão selecionado: `TextFormField(labelText: 'CVV', obscureText: true, maxLength: 4, keyboardType: number)`.
- `ListTile(title: Text('Total a pagar'), trailing: Text(formatPrice(total), style: titleLarge))`.
- `FilledButton('Confirmar pagamento')` em `bottomNavigationBar`; `TextButton.icon(Icons.add, 'Adicionar novo cartão')`.
- Eliminar `Transform.rotate` e os retângulos decorativos.

**(c)** **G**

---

## 3. Riscos catalogados

### 3.1 Overflow / layout com altura fixa

| Arquivo:linha | Risco |
|---|---|
| `auth/register_page.dart:121-133` | `Stack(300)` + `Container(220)` para **4 campos** com validação → corte garantido |
| `address/address_form.dart:7-8` | `SizedBox(height: 500)` para o formulário inteiro + teclado |
| `payment/payment_page.dart:192-201` | `Container(height: 250)` com 3 linhas de campos + textos de erro |
| `auth/forgot_password_page.dart:126-135` | `Container(height: 100)` para campo + mensagem de erro |
| `address/add_address_page.dart:76-135` | 3 cards fixos (280 px) + padding em tela de 320 dp |
| `tracking_page.dart:106-108` | `maxHeight: constraints.maxHeight - 48` (número mágico) |
| `shop/check_out_page.dart:82-100` | `Row` com dois `Text` sem `Flexible` na barra de subtotal |
| `shop/check_out_page.dart:102` | `SizedBox(height: 300)` fixo para a lista do carrinho |
| `payment/promo_item.dart:32-34` | `Container(width: 200)` fixo dentro de `Row` |
| `shop/components/credit_card.dart:7-8` | `200×250` fixos com 4 textos |
| `notifications_page.dart:236-249` | `Flexible(Column)` com textos longos, sem `overflow` |
| `search_page.dart:165-166` | `NeverScrollableScrollPhysics` em conteúdo que pode crescer |
| `profile_page.dart:58` | `height: 150` fixa com `IconButton` + label sob `textScaler` alto |

### 3.2 Imagens desproporcionais ou mal recortadas

| Arquivo:linha | Problema |
|---|---|
| `rating/rating_page.dart:54-65` | `Container(shape: circle)` **não recorta** o `Image.network` → quadrado sobre o círculo |
| `intro_page.dart:36-42, 67-73, 98-104` | assets 244×195 / 226×244 / 264×238 forçados em **200×200 sem `fit`** |
| `intro_page.dart:19-21` | `DecorationImage` **sem `fit`** → imagem 374×476 repetida/centralizada |
| `profile_page.dart:23-26` | `background.jpg` (375×812) como `CircleAvatar` |
| `notifications_page.dart:45-48, 133-136` | idem, como foto de pessoa |
| `select_card_page.dart:106-110` | idem, como logo da loja |
| `tracking_page.dart:36-38` | `Group 444.png` (397×663) como fundo de tela inteira em `BoxFit.contain` |
| `category/components/staggered_category_card.dart:80-85` | `Image.network` sem `width`/`height` dentro de container de altura animada |
| `notifications_page.dart:221-235` | `SizedBox(110)` → `SizedBox(90)` aninhados, sem `loadingBuilder`/`errorBuilder` |
| `profile_page.dart:111` | `settings_icon.png` **100×100** renderizado em 30 px ao lado de assets de 24 px |
| `shop/check_out_page.dart:58` | `denied_wallet.png` **28×23** (não quadrado) como ícone de AppBar |

### 3.3 Ícones em asset que devem virar `Icons.*`

Migração 1-para-1 proposta (permite **apagar `assets/icons/` inteiro** e sair de `flutter_svg`):

| Asset | Onde | Substituir por |
|---|---|---|
| `truck.png` (46×46) | `profile_page.dart:67`, `tracking_page.dart:124` | `Icons.local_shipping_outlined` |
| `card.png` (33×33) | `profile_page.dart:81` | `Icons.credit_card_outlined` |
| `contact_us.png` (33×33) | `profile_page.dart:96` | `Icons.support_agent` |
| `settings_icon.png` (100×100) | `profile_page.dart:111` | `Icons.settings_outlined` |
| `support.png` (24×24) | `profile_page.dart:120` | `Icons.headset_mic_outlined` |
| `faq.png` (24×24) | `profile_page.dart:130` | `Icons.help_outline` |
| `language.png` (19×19) | `settings_page.dart:54` | `Icons.translate` |
| `country.png` (19×19) | `settings_page.dart:60` | `Icons.public` |
| `notifications.png` (19×19) | `settings_page.dart:66` | `Icons.notifications_outlined` |
| `legal.png` (19×19) | `settings_page.dart:72` | `Icons.gavel` |
| `about_us.png` (19×19) | `settings_page.dart:78` | `Icons.info_outline` |
| `change_pass.png` (19×19) | `settings_page.dart:93` | `Icons.lock_outline` |
| `sign_out.png` (19×19) | `settings_page.dart:99` | `Icons.logout` |
| `denied_wallet.png` (28×23) | `check_out_page.dart:58` | `Icons.account_balance_wallet_outlined` |
| `comment.png` (20×20) | `rating/rating_page.dart:26` | `Icons.rate_review_outlined` |
| `address_home.png` (32×32) | `add_address_page.dart:86, 114` | `Icons.home_outlined` |
| `address_work.png` (28×28) | `add_address_page.dart:145` | `Icons.work_outline` |
| `search_icon.svg` | `search_page.dart:114`, `category_list_page.dart:61` | `Icons.search` |
| `red_clear.png` (24×24) | `product/components/shop_product.dart:80` | `Icons.close` / `Icons.delete_outline` |
| `category_icon.png`, `profile_icon.png`, `home_icon.svg`, `cart_icon.svg` | barra inferior (em refatoração pelo agente principal) | `Icons.grid_view_outlined`, `Icons.person_outline`, `Icons.home_outlined`, `Icons.shopping_cart_outlined` |

**Ganho:** –21 arquivos de asset, –1 dependência (`flutter_svg`), tamanho de ícone consistente (24 dp),
cor automática pelo tema, suporte a modo escuro e a `IconTheme`, e nitidez em qualquer densidade de tela.

### 3.4 Bugs funcionais encontrados durante a auditoria

| Severidade | Arquivo:linha | Bug |
|---|---|---|
| 🔴 Crash | `category/category_list_page.dart:22, 74, 80` | `.clear()` sobre `Category.all` (`const List`) → `Unsupported operation` ao digitar na busca |
| 🔴 Segurança | `settings/change_password_page.dart:93, 114, 135` | campos de senha **sem `obscureText`** |
| 🔴 Funcional | `settings/notifications_settings_page.dart:20-42` | nenhum switch persiste o valor (mutação de parâmetro local) |
| 🔴 Funcional | `payment/payment_page.dart:51-53` | botão "Adicionar Cartão" sem `onTap` |
| 🔴 Funcional | `payment/unpaid_page.dart:13-15` | botão "Pagar Agora" sem `onTap` |
| 🔴 Funcional | `settings/change_password_page.dart:17` | botão "Confirmar Alteração" com `onTap: () {}` |
| 🟠 UX errada | `rating/rating_dialog.dart:11-15` | diálogo de avaliação com botão "Pagar Agora" indo para o checkout |
| 🟠 Estado | `rating/rating_dialog.dart:94-95` | `TextEditingController()` criado no `build` → texto perdido |
| 🟠 Estado | `search_page.dart:120-122` | `clear()` fora de `setState` |
| 🟠 Vazamento | `search_page.dart:61-63` | `dispose()` não descarta os controllers |
| 🟠 Vazamento | `category/components/staggered_category_card.dart:139-148` | `AnimationController` sem `dispose()` |
| 🟠 Exceção | `tracking_page.dart:137` | `firstWhere` sem `orElse` |
| 🟠 A11y | `intro_page.dart:168-170` | `Opacity(0)` mantém o botão tocável |
| 🟠 A11y | `tracking_page.dart:87` | `semanticsLabel: '...'` |
| 🟠 Web | `settings/notifications_settings_page.dart:1`, `legal_about_page.dart:1` | `import 'dart:io'` quebra o build web |
| 🟡 Limpeza | `shop/check_out_page.dart:162-196` | `class Scroll` morta com `// TODO` |
| 🟡 Limpeza | `payment/promo_item.dart:69-99` | 30 linhas comentadas |
| 🟡 Limpeza | `rating/rating_page.dart:115, 210` | `print()` em produção |
| 🟡 Limpeza | `category/components/staggered_category_card.dart:168` | `var timeDilation = 10.0;` sem uso |

---

## 4. Sistema de design

Proposta para virar um `ThemeData` central em `lib/main.dart`, substituindo
`app_properties.dart` (que passa a ser apenas tokens de espaçamento/raio).

### 4.1 Paleta — `ColorScheme.fromSeed`

Semente: **`Color(0xFF1565C0)`** (o atual `darkYellow`, azul institucional da marca).
`fromSeed` gera os 30+ papéis do M3 com contraste garantido — inclusive `error`,
`*Container`, `outline` e os `surfaceContainer*` que hoje são improvisados com
`Colors.grey[100]`, `#F9F9F9` e `#FAF1E2`.

```dart
const Color kBrandSeed = Color(0xFF1565C0);

final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: kBrandSeed,
  brightness: Brightness.light,
);
final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kBrandSeed,
  brightness: Brightness.dark,
);
```

**Mapa de migração das constantes atuais:**

| Constante atual | Uso hoje | Passa a ser |
|---|---|---|
| `yellow` `#2196F3` | fundo de destaque, chevrons, badges | `colorScheme.primary` |
| `mediumYellow` `#1E88E5` | chips selecionados | `colorScheme.primary` |
| `darkYellow` `#1565C0` | preços | `colorScheme.primary` |
| `transparentYellow` rgba(33,150,243,.7) | overlays e **sombras azuis** | `colorScheme.scrim.withValues(alpha: .32)` (overlay) / remover as sombras coloridas |
| `darkGrey` `#202020` | todo texto | `colorScheme.onSurface` |
| `Colors.grey[100]` / `#F9F9F9` | fundos de tela | `colorScheme.surface` |
| fundo de card branco | cards | `colorScheme.surfaceContainerLow` |
| campos `Colors.grey[200]` | `TextField` | `colorScheme.surfaceContainerHighest` |
| `#FAF1E2` (bege do FAQ) | painel de resposta | `colorScheme.surfaceContainerLow` |
| `#FF8993` (corações) | avaliação | `Colors.amber` ou `colorScheme.tertiary` |
| `mainButton` (gradiente) | 12 botões | **remover** → `FilledButton` (`primary`/`onPrimary`) |
| `Colors.red` / `#F94D4D` | erros e "Recusar" | `colorScheme.error` / `onErrorContainer` |
| roxos `#353A85`, `#A647DD`, `#454ECA`, `deepPurple` | cartões | `colorScheme.primaryContainer` / `tertiaryContainer` |

Regra: **nenhum `Color(0x…)` literal dentro de `lib/screens/`.** Toda cor vem de
`Theme.of(context).colorScheme`.

### 4.2 Tipografia

**Pré-requisito:** adicionar os pesos que faltam ao `pubspec.yaml` (hoje só existe
`Montserrat-Regular`, o que torna todo negrito do app sintético) e remover
`NunitoSans`, que não é usada:

```yaml
fonts:
  - family: Montserrat
    fonts:
      - asset: fonts/Montserrat-Regular.ttf   # w400
      - asset: fonts/Montserrat-Medium.ttf
        weight: 500
      - asset: fonts/Montserrat-SemiBold.ttf
        weight: 600
      - asset: fonts/Montserrat-Bold.ttf
        weight: 700
```

Escala (baseada na `TextTheme` do M3, ajustada ao produto):

| Papel M3 | Tamanho / altura | Peso | Uso no app |
|---|---|---|---|
| `displaySmall` | 36 / 44 | 700 | nota média em Avaliações, splash |
| `headlineMedium` | 28 / 36 | 700 | títulos de tela cheia (Cadastro, Intro) |
| `headlineSmall` | 24 / 32 | 700 | títulos de seção grandes, preço no detalhe |
| `titleLarge` | 22 / 28 | 600 | `AppBar`, total do pedido |
| `titleMedium` | 16 / 24 | 600 | nome de produto, título de `ListTile` |
| `titleSmall` | 14 / 20 | 600 | cabeçalhos de seção ("Geral", "Conta") |
| `bodyLarge` | 16 / 24 | 400 | texto de formulário, descrições |
| `bodyMedium` | 14 / 20 | 400 | **corpo padrão**, subtítulos de `ListTile` |
| `bodySmall` | 12 / 16 | 400 | **menor tamanho permitido** — timestamps, legendas |
| `labelLarge` | 14 / 20 | 600 | rótulo de botões |

**Regra dura:** proibido `fontSize` abaixo de **12**. Hoje existem `fontSize: 8`
(`add_address_page.dart:91, 122, 152`) e `fontSize: 10` em ~12 pontos
(`notifications_page.dart`, `select_card_page.dart`, `rating_page.dart`).
Nunca declarar `fontSize` inline: usar `Theme.of(context).textTheme.*`.

### 4.3 Raio de borda

| Token | Valor | Aplicação |
|---|---|---|
| `radiusXs` | 4 | `Chip` pequeno, indicador de página |
| `radiusSm` | 8 | miniaturas de produto, `Ink.image` |
| `radiusMd` | **12** | **padrão**: `Card`, `TextField`, `ExpansionTile`, containers |
| `radiusLg` | 16 | cards de destaque, banners |
| `radiusXl` | 28 | `Dialog`, `BottomSheet` (padrão M3) |
| `StadiumBorder` | — | `FilledButton`, `OutlinedButton`, `Chip`, `SearchBar` |

Hoje coexistem 5, 8, 9, 10, 24 e 45 sem critério (`BorderRadius.circular(5)` em 14
lugares, `9.0` nos 12 botões gradiente, `45` nos chips manuais da busca). Padronizar em **12**.

### 4.4 Elevação e sombra

M3 usa `surfaceTintColor` + elevação em níveis; **sombras coloridas não existem no sistema**.

| Nível | dp | Uso |
|---|---|---|
| 0 | 0 | fundo de tela, `AppBar` no topo do scroll, `SearchBar` |
| 1 | 1 | **`Card` padrão**, `AppBar` com conteúdo rolado (`scrolledUnderElevation`) |
| 2 | 3 | `FilledButton` pressionado, `Chip` selecionado |
| 3 | 6 | `Dialog`, `BottomSheet`, `Menu` |

**Eliminar:**
- `const List<BoxShadow> shadow` de `app_properties.dart:15-17` (usada em 8 telas);
- a `boxShadow` **azul** de `profile_page.dart:52-56` (`color: transparentYellow`);
- as `BoxShadow(offset: (0,5), blur: 10)` dos 12 botões gradiente;
- `AppBar(elevation: 0)` manual — vira `appBarTheme`.

### 4.5 Espaçamento

Grade base **4 dp**: `4 · 8 · 12 · 16 · 24 · 32 · 48`.

| Token | Valor | Uso |
|---|---|---|
| `spaceXs` | 4 | entre `Icon` e `Text` colados |
| `spaceSm` | 8 | interno de `Chip`, entre linhas de um card |
| `spaceMd` | 12 | entre itens de lista |
| `spaceLg` | **16** | **padding horizontal padrão de tela**, padding interno de `Card` |
| `spaceXl` | 24 | entre seções |
| `spaceXxl` | 32 | antes de um CTA principal |

Altura mínima de alvo de toque: **48 dp**. Altura de botão principal: **52 dp**
(hoje os botões gradiente têm **80 dp**, quase o dobro do recomendado).

### 4.6 `ThemeData` proposto para `lib/main.dart`

```dart
ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: kBrandSeed, brightness: brightness);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'Montserrat');

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    // canvasColor: NÃO sobrescrever (o `Colors.transparent` atual quebra Dropdown/Drawer)

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),

    cardTheme: CardTheme(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: base.textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    chipTheme: ChipThemeData(shape: const StadiumBorder()),
    dividerTheme: DividerThemeData(space: 1, thickness: 1, color: scheme.outlineVariant),
    bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

E no `MaterialApp`:

```dart
MaterialApp(
  title: 'Bem Estar Cem',
  debugShowCheckedModeBanner: false,
  theme: _buildTheme(Brightness.light),
  darkTheme: _buildTheme(Brightness.dark),
  themeMode: ThemeMode.system,
  locale: const Locale('pt', 'BR'),
  supportedLocales: const [Locale('pt', 'BR')],
  localizationsDelegates: const [                 // requer flutter_localizations no pubspec
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: const SplashScreen(),
)
```

### 4.7 O que sai do `pubspec.yaml`

| Pacote | Motivo |
|---|---|
| `rubber: ^1.0.1` | sem manutenção; substituído por `showModalBottomSheet` / `DraggableScrollableSheet` (`search_page.dart`) |
| `card_swiper: ^3.0.1` | usado só no carrossel falso de cartões (`check_out_page.dart:131`) → vira lista de `Card` |
| `flutter_svg: ^2.0.10+1` | os 3 SVGs viram `Icons.*` (§3.3) |
| `numberpicker: ^2.1.2` | verificar uso real; quantidade cabe em `IconButton(±)` ou `DropdownMenu` |
| **adicionar** `flutter_localizations` | T-2 |
| **avaliar** `flutter_native_splash` | §2.24 |

---

## 5. Priorização sugerida

| Ordem | Item | Esforço | Justificativa |
|---|---|---|---|
| 1 | `ThemeData` central + fontes + `flutter_localizations` (§4) | M | Habilita todas as outras telas; sem isso cada refatoração recria estilos |
| 2 | Correção dos 6 bugs 🔴 (§3.4) | P | Crash na busca de categorias, senha em texto claro, 3 botões mortos, switches inertes |
| 3 | Migração de ícones `asset` → `Icons.*` (§3.3) | P | Mecânico, alto impacto visual, remove 21 assets e 1 dependência |
| 4 | Fluxo de compra: `check_out` → `payment` → `select_card` (§2.7–2.9, 2.26) | G | Caminho que gera receita (RF-007 a RF-010) |
| 5 | `search_page` (§2.16) | G | RF-004; remove `rubber`; filtros hoje não filtram |
| 6 | `notifications_page` (§2.17) | G | Conteúdo de outro produto exposto ao usuário final |
| 7 | `register_page` + `forgot_password_page` (§2.20–2.21) | M | Primeira impressão; formulário espremido em 220 px |
| 8 | `add_address_page` + `address_form` (§2.22) | G | RF-008; campos duplicados e sem validação |
| 9 | Categorias (§2.13–2.15) | M | Remove o último gradiente e a animação manual |
| 10 | `profile_page`, `settings/*`, `faq_page`, `tracking_page`, `intro_page`, `splash_page`, `rating/*` | P–G | Polimento e coerência final |
