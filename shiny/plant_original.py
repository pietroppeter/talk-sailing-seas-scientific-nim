# Nick Strayer's plant app as shared on shinylive.io in 2022 (decoded from the editor link
# in the deep dive deepdive/plant_app.nim). It no longer runs: ui.panel_sidebar and ui.panel_main
# were removed from Shiny. The working version is shiny/plant/app.py.
from shiny import App, render, ui
import matplotlib.pyplot as plt
from math import pi
from numpy import linspace, cos, sin, sqrt

app_ui = ui.page_fluid(
    ui.layout_sidebar(
        ui.panel_sidebar(
            ui.input_slider("n", "Leafiness", 0, 100, 39),
            ui.input_slider("l", "Order", 0, 20, 9),
            ui.input_slider("o", "Waviness", 0, 10, 4),
            ui.input_slider("p", "Simplicity", 0, 1, 0.2),
        ),
        ui.panel_main(
            ui.output_plot("plot"),
        ),
    ),
)

def server(input, output, session):
    @output
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

app = App(app_ui, server, debug=True)
