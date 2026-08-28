"""Python 3.15 import-time degrade: wrapping must load, wrap() still raises.

Products that import wrapping (e.g. ModuleWatchdog) must not crash the process.
wrap() still fail-closes with NotImplementedError when actually used.
"""

import re

import pytest

from ddtrace.internal.compat import MAX_PY_VERSION
from ddtrace.internal.compat import MAX_PY_VERSION_INFO
from ddtrace.internal.compat import NEXT_MAX_PY_VERSION_INFO
from ddtrace.internal.compat import NEXT_PY_UNSUPPORTED_MSG
from ddtrace.internal.compat import PY_315_VERSION_INFO
from ddtrace.internal.compat import PYTHON_VERSION_INFO


_RUNNING_VERSION = f"{PYTHON_VERSION_INFO[0]}.{PYTHON_VERSION_INFO[1]}"
_UNSUPPORTED_MSG = f"This version of CPython is not supported yet: {_RUNNING_VERSION}"


def test_unsupported_msg_includes_running_version():
    assert NEXT_PY_UNSUPPORTED_MSG == _UNSUPPORTED_MSG


def test_max_and_next_max_py_version_constants():
    assert MAX_PY_VERSION == "3.15"
    assert MAX_PY_VERSION_INFO == (3, 15)
    assert NEXT_MAX_PY_VERSION_INFO == (MAX_PY_VERSION_INFO[0], MAX_PY_VERSION_INFO[1] + 1)
    assert NEXT_MAX_PY_VERSION_INFO == (3, 16)


def test_py315_api_floor_is_not_aliased_to_max():
    assert PY_315_VERSION_INFO == (3, 15)
    assert PY_315_VERSION_INFO is not MAX_PY_VERSION_INFO


def test_wrapping_modules_import():
    import ddtrace.internal.bytecode_injection  # noqa: F401
    import ddtrace.internal.module  # noqa: F401
    import ddtrace.internal.wrapping.asyncs  # noqa: F401
    import ddtrace.internal.wrapping.context  # noqa: F401
    import ddtrace.internal.wrapping.generators  # noqa: F401


@pytest.mark.skipif(PYTHON_VERSION_INFO < MAX_PY_VERSION_INFO, reason=f"{MAX_PY_VERSION} wrap() degrade")
def test_wrap_raises_not_implemented_on_315():
    from ddtrace.internal.wrapping import wrap

    def f() -> None:
        return None

    def wrapper(wrapped, args, kwargs):  # noqa: ANN001, ANN202
        return wrapped(*args, **kwargs)

    with pytest.raises(NotImplementedError, match=re.escape(_UNSUPPORTED_MSG)):
        wrap(f, wrapper)


@pytest.mark.skipif(PYTHON_VERSION_INFO < MAX_PY_VERSION_INFO, reason=f"{MAX_PY_VERSION} lazy module degrade")
def test_lazy_module_decorator_without_bytecode_wrap():
    import tests.internal.lazy as lazy_module

    assert lazy_module.new_value == 42


def test_exec_lazy_init_without_source():
    from ddtrace.internal.module import _exec_lazy_init

    ns: dict[str, object] = {}
    exec(compile("def init():\n    exported = 123\n", "<test>", "exec"), ns)
    module_globals: dict[str, object] = {"__name__": "test_lazy_init"}
    _exec_lazy_init(ns["init"], module_globals)
    assert module_globals["exported"] == 123


@pytest.mark.skipif(PYTHON_VERSION_INFO < MAX_PY_VERSION_INFO, reason=f"{MAX_PY_VERSION} debugging products degrade")
def test_debugging_products_load_without_failure():
    from ddtrace.internal.products import ProductManager

    product_manager = ProductManager()
    product_manager._load_products()
    for product_name in (
        "code-origin-for-spans",
        "dynamic-instrumentation",
        "exception-replay",
        "live-debugger",
    ):
        assert product_name not in product_manager._failed
