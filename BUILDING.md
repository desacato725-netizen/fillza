# Compilação do SLEEP Control pela GitHub Actions

O repositório já contém workflows para compilar a tweak com Theos em um runner `macos-15`. O workflow recomendado é **Build SLEEP Control tweak** (`.github/workflows/build-sleep-release.yml`). Ele instala `ldid` e Theos, escolhe o SDK iPhoneOS disponível, compila `arm64` e `arm64e` conforme o `Makefile` e publica um ZIP com a `.dylib`, o `.deb`, o `Makefile`, os arquivos da tela de login e os hashes SHA-256.

## Como executar

Abra a aba **Actions** do repositório, selecione **Build SLEEP Control tweak**, clique em **Run workflow** e escolha a branch `main`. Ao terminar, abra a execução concluída e baixe o artefato `sleep-control-<commit>`. O arquivo `BUILD_INFO.txt` identifica exatamente o commit usado na compilação.

A tela de login está configurada em `LoginViewController.m` para chamar `/api/license/activate` e `/api/license/validate`. Antes de compilar, substitua `API_BASE_URL` pelo domínio público real do painel SLEEP Control. Não coloque segredos administrativos nesse arquivo ou em qualquer arquivo enviado para a IPA.

## Sobre a IPA

Este workflow gera o pacote da tweak e a biblioteca dinâmica sem assinatura de distribuição da Apple. Uma IPA instalável depende do método de distribuição usado e das credenciais de assinatura correspondentes. O workflow não tenta obter, armazenar ou expor certificados; caso seja necessário assinar uma IPA própria, configure os certificados e perfis como GitHub Actions Secrets seguindo o método de distribuição autorizado para o aplicativo.

Não faça commit de certificados, perfis, chaves privadas ou tokens. O arquivo `SHA256SUMS` deve ser usado para conferir a integridade dos artefatos baixados.
