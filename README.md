# AtlasFastStart

Архив оригинальных установщиков Windows x64 и каталог для восстановления рабочего компьютера.

Снимок **04.10.2026**: **71 установщик**, **9 640 780 950 байт** (9,64 GB / 8,98 GiB). EXE, MSI, MSIX, MSIXBundle и официальный PowerShell-установщик Claude Code. Программы определены по реестру, ярлыкам и папкам профиля; список включает необязательные дополнения Vencord и BetterDiscord.

Полный локальный архив: `D:\AtlasFastStart\Installers`. Откройте **[Start.html](Start.html)** для поиска или **[CATALOGUE.md](CATALOGUE.md)** для полного списка и отдельных инструкций. Сами установщики запускаются вручную.

## GitHub и установщики

[Релиз installers-2026-10-04](https://github.com/V1sioneer/AtlasFastStart/releases/tag/installers-2026-10-04) содержит пять оригинальных установщиков: 7-Zip, Python 3.12, Python 3.14, Node.js 22 и Rustup. Рядом лежат лицензии, соответствующий исходный код 7-Zip и контрольные суммы.

Остальные программы скачиваются из источников авторов через скрипт. Их адреса, размеры и SHA256 сохранены в [catalogue.json](catalogue.json). Бинарные файлы находятся в GitHub Releases, а не в истории Git. Лицензирование описано в [THIRD_PARTY.md](THIRD_PARTY.md).

## Скачать архив на новом Windows-компьютере

Скачайте этот репозиторий как ZIP и распакуйте его. Откройте PowerShell в этой папке.

Посмотреть доступные программы без загрузки:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Download-Installers.ps1 -List
```

Скачать все программы с доступным публичным адресом:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Download-Installers.ps1
```

Скачать только выбранные программы:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Download-Installers.ps1 -Id 7zip.7zip,Obsidian.Obsidian,Discord.Discord
```

Скачать одну категорию в другой каталог:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Download-Installers.ps1 -Category Development -Destination D:\AtlasFastStart
```

Параметр ExecutionPolicy действует только для этого процесса PowerShell; системная политика не меняется. Скрипт скачивает файлы и проверяет их. Он не выполняет установку.

MSI Center и собственный ApexHub сохранены из уже имеющихся настоящих установщиков. Они доступны в локальном архиве; публичного адреса в каталоге для них нет. MSI Center можно получить из Microsoft Store или официального сайта MSI. Для ApexHub используйте исходный проект и его выпуск.

## Проверить файлы

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Verify-Installers.ps1
```

При частичной загрузке:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Verify-Installers.ps1 -AvailableOnly
```

Проверяется каждый SHA256 и размер. Уже имеющийся файл с другим хешем сохраняется и отмечается как ошибка. Загрузки сначала пишутся в `.part` и получают окончательное имя только после проверки.

Некоторые URL авторов всегда отдают последнюю версию. Если файл у автора обновился, сохранённый SHA256 перестанет совпадать. Скрипт сообщит об этом и сохранит только `.part`; обновлять запись каталога нужно после проверки новой версии и её источника.

## Что требует дополнительных загрузок

Visual Studio, Build Tools, Windows SDK, SQL Express, Rustup, Steam, Logitech G HUB, Roblox и установщики дополнений могут догружать компоненты. Unity Hub устанавливает сам Hub; редактор **6000.5.3f1** и модули платформ выбираются отдельно. Игры скачиваются через соответствующие лаунчеры.

Codex / ChatGPT desktop сохранён как официальный x64 MSIX. Для офлайн-развёртывания локально сохранён `Support\Codex\ChatGPT-License.xml`. При повторной загрузке получите офлайн-лицензию из [официальной инструкции OpenAI](https://learn.chatgpt.com/docs/enterprise/windows-deployment). Для работы учётной записи нужен интернет. Пакеты MSIX устанавливаются через App Installer; необходимые Windows-компоненты могут потребоваться отдельно.

GameGuard, SPACE LCD, ASRock Auto Driver Installer, ApexTweaks, переносимые утилиты и встроенные Store-программы описаны в отдельном разделе каталога. Установленные EXE, пользовательские профили и файлы игр не использовались как замена установщикам.

## Arch Linux

На E: сохранён официальный **Arch Linux 2026.10.01 x86_64** — актуальный выпуск на момент сбора по [официальной странице загрузок](https://archlinux.org/download/).

```text
E:\archlinux-2026.10.01-x86_64.iso
Размер: 1 640 497 152 байта
SHA256: 684ded26c63240ff4a41e8c25ee84ea6da233f557364821f13d12c2b0a9059a5
```

SHA256 совпал с [официальным sha256sums.txt](https://archlinux.org/iso/2026.10.01/sha256sums.txt). Рядом сохранены файл сумм, PGP-подпись и JSON с результатом проверки. PGP-подпись скачана, отдельная проверка ключом PGP не выполнялась. ISO не включён в этот GitHub-релиз.

## Структура

```text
Start.html                   каталог с поиском и категориями
CATALOGUE.md                 полный список и ручные позиции
catalogue.json               адреса, версии, размеры и SHA256
Download-Installers.ps1      повторная загрузка из источников
Verify-Installers.ps1        проверка локальных файлов
SHA256SUMS.txt               суммы всех установщиков
ThirdPartyLicenses/          лицензии публичных зеркал
Installers/                 полный локальный архив, вне Git
Sources/                    соответствующий исходный код 7-Zip, вне Git
Support/                    офлайн-лицензия Codex, вне Git
Local/                      исходная инвентаризация и проверки, вне Git
verification/               доказательства проверки и выпуска, вне Git
```

MIT-лицензия репозитория относится к собственным скриптам и документации AtlasFastStart. Программы других авторов сохраняют свои лицензии и условия использования.
