from django.apps import AppConfig


class CoreConfig(AppConfig):
    name = 'core'

def ready(self):
    import core.signals  # Import the signals module to register signal handlers