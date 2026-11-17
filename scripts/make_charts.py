from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "output"
CHARTS = ROOT / "assets" / "charts"
CHARTS.mkdir(parents=True, exist_ok=True)

plt.rcParams.update({
    "figure.dpi": 150,
    "font.size": 10,
    "axes.spines.top": False,
    "axes.spines.right": False,
})


def read(subdir, prefix):
    """Load the newest CSV in output/<subdir>/ whose name starts with <prefix>_."""
    matches = sorted((OUT / subdir).glob(f"{prefix}_*.csv"))
    if not matches:
        raise FileNotFoundError(f"No file matching {prefix}_*.csv in {OUT / subdir}")
    path = matches[-1]  # newest timestamp if the query was exported more than once
    print(f"reading {subdir}/{path.name[:50]}...")
    # thousands="," keeps numbers such as "99,441" readable if the export formatted them
    return pd.read_csv(path, thousands=",")


def save(fig, name):
    fig.tight_layout()
    fig.savefig(CHARTS / f"{name}.png", bbox_inches="tight")
    plt.close(fig)
    print(f"saved assets/charts/{name}.png")


def chart_funnel():
    df = read("02_funnel", "_A")
    rows = list(zip(df["stage"].str.replace("_", " "), df["orders"], df["pct_of_purchased"]))[::-1]
    fig, ax = plt.subplots(figsize=(8, 3.6))
    bars = ax.barh([r[0] for r in rows], [r[1] for r in rows], color="#4C78A8")
    for bar, (_, n, pct) in zip(bars, rows):
        ax.text(bar.get_width() + 1000, bar.get_y() + bar.get_height() / 2,
                f"{int(n):,} ({pct:.2f}%)", va="center")
    ax.set_xlim(0, df["orders"].max() * 1.3)
    ax.set_xlabel("Orders")
    final_pct = df["pct_of_purchased"].iloc[-1]
    ax.set_title(f"Order fulfilment funnel: {final_pct:.1f}% of orders reach the customer")
    save(fig, "chart_funnel")


def chart_heatmap():
    df = read("03_retention_cohort", "_A")
    df = df[(df["month_offset"] >= 1) & (df["month_offset"] <= 12)]
    pv = df.pivot(index="cohort_month", columns="month_offset", values="retention_pct").sort_index()
    data = np.ma.masked_invalid(pv.values)
    cmap = plt.get_cmap("Blues").copy()
    cmap.set_bad("#EEEEEE")
    fig, ax = plt.subplots(figsize=(10, 7))
    im = ax.imshow(data, cmap=cmap, aspect="auto", vmin=0, vmax=0.8)
    ax.set_xticks(range(pv.shape[1]))
    ax.set_xticklabels(pv.columns)
    ax.set_yticks(range(pv.shape[0]))
    ax.set_yticklabels(pv.index)
    for i in range(pv.shape[0]):
        for j in range(pv.shape[1]):
            v = pv.values[i, j]
            if not np.isnan(v):
                ax.text(j, i, f"{v:.2f}", ha="center", va="center", fontsize=7,
                        color="white" if v > 0.5 else "black")
    ax.set_xlabel("Months since first purchase")
    ax.set_ylabel("Cohort (first purchase month)")
    ax.set_title(f"Monthly cohort retention (%), months 1-12 (max {df['retention_pct'].max():.2f}%)")
    fig.colorbar(im, ax=ax, label="Retention (%)")
    save(fig, "chart_retention_heatmap")


def chart_pooled():
    df = read("03_retention_cohort", "_B")
    df = df[(df["month_offset"] >= 1) & (df["month_offset"] <= 12)]
    first = df["pooled_retention_pct"].iloc[0]
    later_max = df["pooled_retention_pct"].iloc[1:].max()
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(df["month_offset"], df["pooled_retention_pct"], marker="o", color="#4C78A8")
    ax.set_ylim(0, 1)
    ax.set_xticks(df["month_offset"])
    ax.set_xlabel("Months since first purchase")
    ax.set_ylabel("Customers who purchased again (%)")
    ax.set_title(f"Pooled retention: {first:.2f}% in month 1, at most {later_max:.2f}% afterwards")
    save(fig, "chart_retention_pooled")


def chart_late():
    df = read("05_extra_analysis", "_E2").sort_values("delivery_bucket")
    labels = ["On time\nor early", "Late\n1-3 days", "Late\n4-7 days", "Late\n8+ days"]
    colors = ["#59A14F", "#E15759", "#E15759", "#E15759"]
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))

    axes[0].bar(labels, df["avg_review"], color=colors)
    axes[0].set_ylim(0, 5)
    axes[0].set_ylabel("Average review score")
    axes[0].set_title("Average review score")
    for x, v in enumerate(df["avg_review"]):
        axes[0].text(x, v + 0.08, f"{v:.2f}", ha="center")

    axes[1].bar(labels, df["pct_low_review"], color=colors)
    axes[1].set_ylim(0, 100)
    axes[1].set_ylabel("Orders with 1-2 star review (%)")
    axes[1].set_title("Share of low reviews")
    for x, v in enumerate(df["pct_low_review"]):
        axes[1].text(x, v + 1.5, f"{v:.1f}%", ha="center")

    fig.suptitle("Late delivery vs customer reviews (delivered orders)")
    save(fig, "chart_late_vs_review")


def chart_category():
    df = read("04_segmentation", "_B").sort_values("pct_low_review")
    fig, ax = plt.subplots(figsize=(8, 6))
    bars = ax.barh(df["category"], df["pct_low_review"], color="#F28E2B")
    for bar, v in zip(bars, df["pct_low_review"]):
        ax.text(v + 0.3, bar.get_y() + bar.get_height() / 2, f"{v:.1f}%", va="center")
    ax.set_xlabel("Orders with 1-2 star review (%)")
    ax.set_title("Low-review share, top 15 categories by order value")
    save(fig, "chart_category_low_review")


if __name__ == "__main__":
    chart_funnel()
    chart_heatmap()
    chart_pooled()
    chart_late()
    chart_category()
    print("Done.")