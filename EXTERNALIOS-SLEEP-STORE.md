# ExternalIOS + SLEEP STORE — gate unificado da Filza

A cópia `ExternalIOS-sleep-store-filza-gate-black-launch-v2.ipa` foi preparada a partir de `/home/ubuntu/upload/ExternalIOS.ipa`, sem modificar a source original. O executável `ARIFIxIOS` recebe o load command `@executable_path/Frameworks/SleepStoreAuth.dylib`, e a IPA contém somente o gate `SleepStoreAuth.dylib`; a antiga `SleepStoreVisual.dylib` não é incluída.

O gate usa o mesmo controlador e o mesmo fluxo de licença da Filza: keys com prefixo `SLEEP-`, ativação em `/api/license/activate`, validação em `/api/license/validate`, vínculo por instalação/dispositivo e armazenamento protegido no Keychain. A tela de lançamento foi ajustada para o storyboard preto reutilizado da Filza, com uma launch image preta como fallback; a referência ao storyboard roxo original foi substituída no `Info.plist`. O endpoint configurado é `https://sleeppanel-by9jc9qe.manus.space`. A tela própria usa tema preto, exibe `SLEEP STORE`, `sleepffx` e `dev|cholyyk`, e oferece o botão Discord clicável para `https://discord.gg/sleepff`.

## Escopo final

Esta versão **não preserva o login original como fluxo de ativação**. O login original permanece apenas como parte do binário-base da aplicação, enquanto o gate SLEEP STORE é o fluxo de entrada responsável pela ativação e validação das keys. A integração não usa a camada visual anterior que podia sobrepor mensagens ao campo ou ao teclado.

## Verificação estática realizada

A IPA passou em `unzip -t`. O executável contém o load command de `SleepStoreAuth.dylib`, a cópia empacotada contém uma única dylib de integração, e os bytes compilados contêm `SLEEP STORE`, `sleepffx`, `dev|cholyyk`, o link do Discord, o domínio publicado e as duas rotas `/api/license/*`. Hash SHA-256 da entrega v2: `d7bf57f13f79cc07bb55ccb89de15018874068515824b43081f8dad3ac9eda30`.

## Limitações de runtime

A IPA é **unsigned** após a alteração e precisa ser assinada e instalada em um dispositivo iOS compatível. O ambiente de compilação não possui dispositivo ou simulador iOS para confirmar runtime. Antes de distribuir, teste a abertura do gate, a ativação com uma key `SLEEP-`, a reabertura após ativação, a rejeição de uma key inválida e o clique no Discord. A ausência da sobreposição e o funcionamento efetivo das keys só podem ser confirmados no dispositivo instalado.
