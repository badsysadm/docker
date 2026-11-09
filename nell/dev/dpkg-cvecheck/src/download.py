"""Общая политика повторной загрузки CVE-фидов."""

import http.client
import json
import tarfile
import time
import zipfile


RETRYABLE_ERRORS = (
    EOFError,
    OSError,
    http.client.IncompleteRead,
    json.JSONDecodeError,
    tarfile.TarError,
    zipfile.BadZipFile,
)


def retry_download(source, action):
    for attempt in range(1, 4):
        try:
            return action()
        except RETRYABLE_ERRORS as error:
            reason = str(error) or type(error).__name__
            if attempt == 3:
                raise RuntimeError(
                    f"{source}: загрузка или чтение фида не удались после "
                    f"3 попыток: {reason}. Неполные данные не опубликованы."
                ) from error

            delay = 5 * attempt
            print(
                f"{source}: обрыв или ошибка загрузки/чтения фида "
                f"(попытка {attempt}/3): {reason}. "
                f"Повтор через {delay} с...",
                flush=True,
            )
            time.sleep(delay)
