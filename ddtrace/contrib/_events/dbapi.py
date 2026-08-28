from dataclasses import dataclass
from typing import Union

from ddtrace.internal.core.events import Event


@dataclass
class DbApiEvent(Event):
    """A database query shared by instrumentation and product subscribers."""

    event_name = "dbapi.query"

    query: Union[str, bytes]
    span_name_prefix: str
