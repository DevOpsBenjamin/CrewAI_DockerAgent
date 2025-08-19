from crewai.tools import tool
import os

@tool('Execute a shell command')
def shell_tool(command: str) -> str:
    """Executes a shell command and returns the output."""
    return os.popen(command).read()