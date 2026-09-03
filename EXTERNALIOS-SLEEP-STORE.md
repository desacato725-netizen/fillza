# ExternalIOS + SLEEP STORE

A cópia `ExternalIOS-sleepffx-black.ipa` foi preparada a partir de `ExternalIOS.ipa` sem alterar o arquivo original. O executável arm64 `ARIFIxIOS` recebeu um load command para `@executable_path/Frameworks/SleepStoreAuth.dylib`, e a dylib genérica contém a tela preta SLEEP STORE com `sleepffx`, assinatura `dev|cholyyk`, as rotas `/api/license/activate` e `/api/license/validate`, o domínio `https://sleeppanel-by9jc9qe.manus.space` e a marca d’água clicável do Discord em `https://discord.gg/sleepff`.

## Limitações importantes

Esta IPA é **unsigned** após a alteração. Ela precisa ser assinada e instalada no ambiente iOS compatível do usuário antes de qualquer distribuição. O ambiente de compilação não fornece um dispositivo ou simulador iOS para confirmar a execução real.

O app original já possui um login nativo dentro do executável. A integração adicionada é um gate sobreposto por injeção; o login original continua presente no binário e pode coexistir ou conflitar visualmente até ser validado em runtime. Não declarar a integração como validada em dispositivo antes de confirmar a abertura do gate, a ativação com uma key `SLEEP-`, a validação subsequente e o comportamento ao fechar o app e reabri-lo.

## Verificação estática realizada

A IPA passou em `unzip -t`. O executável contém o load command da dylib e a dylib é universal para arm64/arm64e. A presença dos marcadores de branding foi confirmada nos bytes compilados, incluindo as formas UTF-16 usadas pelo Mach-O. O hash SHA-256 da cópia preparada deve ser conferido no arquivo de entrega ao transferi-la. Essa é uma verificação estática; a abertura da tela e o clique no Discord ainda precisam ser confirmados em iOS.
