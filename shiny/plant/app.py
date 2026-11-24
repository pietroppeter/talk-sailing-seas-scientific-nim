# Nick Strayer's plant app (https://twitter.com/NicholasStrayer/status/1554523619379892225),
# updated for Shiny 1.x: ui.page_sidebar and ui.sidebar replace ui.panel_sidebar and
# ui.panel_main, which were removed (the original is shiny/plant_original.py).
# scripts/shinylive.sh exports it to docs/shiny/plant/, where it runs in the browser with Pyodide.
from shiny import App, render, ui
import matplotlib.pyplot as plt
from math import pi
from numpy import linspace, cos, sin, sqrt

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.input_slider("n", "Leafiness", 0, 100, 39),
        ui.input_slider("l", "Order", 0, 20, 9),
        ui.input_slider("o", "Waviness", 0, 10, 4),
        ui.input_slider("p", "Simplicity", 0, 1, 0.2),
    ),
    ui.output_plot("plot"),
)

def server(input, output, session):
    @render.plot(alt="A plant")
    def plot():
        t = linspace(0, input.n() * pi / 2, 1000)
        x = t * cos(t) ** 3
        y = input.l() * t * sqrt(abs(cos(t))) + t * sin(input.p() * t) * cos(
            input.o() * t
        )
        fig, ax = plt.subplots()
        ax.plot(x, y, c="green")
        return fig

app = App(app_ui, server)
