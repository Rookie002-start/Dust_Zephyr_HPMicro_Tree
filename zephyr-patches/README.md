# HPM upstream patches

The active patches target clean community checkouts:

| Target | Base | Active patch |
| --- | --- | --- |
| `sdk_env` | `v1.11.0` | `sdk_env/0001-hpm_misc-dlm-ilm.diff` |
| `zephyr_sdk_glue` | `v0.7.0` | `sdk_glue/0001-hpm-zephyr-glue-v0.7.0-local.diff` |

`cherryusb/` is optional and is applied only when its checkout is supplied.
`legacy/` is retained for history and is never applied automatically.

Run `../apply-patches.sh --check` to validate the expected layout, or
`../apply-patches.sh` to apply the patches. Zephyr patches are maintained by
the sibling `Dust_Zephyr_Tree` repository.
