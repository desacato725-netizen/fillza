# ExternalIOS + SLEEP STORE — gate unificado da Filza

A cópia `ExternalIOS-native-rain-sleep-store-final-v3.ipa` foi preparada a partir de `/home/ubuntu/upload/ExternalIOS.ipa`, sem modificar a source original. O executável `ARIFIxIOS` recebe o load command `@executable_path/Frameworks/SleepNativeBridge.dylib`, e a IPA contém somente o bridge nativo `SleepNativeBridge.dylib`; não há `SleepStoreAuth.dylib` ou `SleepStoreVisual.dylib` adicionais.

O bridge mantém a tela nativa preta e branca de chuva da ExternalIOS, reaproveita seus campos e botão sem criar um segundo cartão, e direciona a ativação para o mesmo fluxo da Filza: keys `SLEEP-`, `/api/license/activate`, `/api/license/validate`, vínculo por instalação/dispositivo e armazenamento protegido no Keychain. O endpoint é `https://sleeppanel-by9jc9qe.manus.space`; o status mostra `sleepffx · dev|cholyyk` e há Discord clicável em `https://discord.gg/sleepff`.

## Escopo final

Esta versão preserva a tela nativa de chuva como a única tela de entrada visível. Não apresenta o cartão SLEEP STORE separado e não usa a camada visual anterior que podia sobrepor mensagens ao campo ou ao teclado; a ação do controle nativo é substituída pelo bridge SLEEP STORE.

## Verificação estática realizada

A IPA passou em `unzip -t`. O executável contém o load command de `SleepNativeBridge.dylib`, a cópia empacotada contém uma única dylib nativa, o binário-base mantém `ARIFIAnimatedBackgroundView` e os bytes compilados contêm `SLEEP STORE`, `sleepffx`, `dev|cholyyk`, o link do Discord, o domínio publicado, as duas rotas `/api/license/*` e o marcador de reinstalação. Hash SHA-256 da entrega nativa: `3c0db2e47c0db50a248488193083dfbf1e93a307dcbd3781995a0848780ccd46`.

## Limitações de runtime

A IPA é **unsigned** após a alteração e precisa ser assinada e instalada em um dispositivo iOS compatível. O ambiente de compilação não possui dispositivo ou simulador iOS para confirmar runtime. Antes de distribuir, teste a abertura direta da tela de chuva, a ativação com uma key `SLEEP-`, a reabertura após ativação, a rejeição de uma key inválida e o clique no Discord. A ausência da sobreposição e o funcionamento efetivo das keys só podem ser confirmados no dispositivo instalado.
