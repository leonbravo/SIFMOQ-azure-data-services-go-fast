function(notebookName = "")
{
	local nbCells = import "../output/cells.json",
	"name": notebookName,
	"properties": {
		"folder": {
			"name": "FrameworkNotebooks"
		},
		"nbformat": 4,
		"nbformat_minor": 2,
		"metadata": {
			"kernelspec": {
				"name": "synapse_pyspark",
				"display_name": "python"
			},
			"language_info": {
				"name": "python"
			}
		},
		"cells": nbCells.cells
	}
}
