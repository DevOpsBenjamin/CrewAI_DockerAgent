#!/usr/bin/env python
from autocoder.crew import Autocoder

def run():
    """
    Run the crew.
    """
    inputs = {
        'command': 'ls -F',
    }
    
    try:
        Autocoder().crew().kickoff(inputs=inputs)
    except Exception as e:
        raise Exception(f"An error occurred while running the crew: {e}")
