#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


# In[2]:


df = pd.read_csv(r"D:\Project\Airline_Delay_Cause_analysis.csv")


# In[3]:


print(df.head())


# In[5]:


print(df.info())


# In[6]:


print(df.describe())


# In[7]:


print(df.isnull().sum())


# In[8]:


df["delay_rate"] = df["delay_rate"].fillna(0)
df["cancellation_rate"] = df["cancellation_rate"].fillna(0)
df["diversion_rate"] = df["diversion_rate"].fillna(0)


# In[9]:


print(df.isnull().sum())


# In[10]:


df.columns = df.columns.str.lower().str.replace(" ", "_")


# In[11]:


df = df.drop_duplicates()


# In[14]:


df["total_delay"] = (
    df["carrier_delay"] +
    df["weather_delay"] +
    df["delay_attributed_to_the_nas"] +
    df["security_delay"] +
    df["late_aircraft_delay"]
)


# In[15]:


df["weather_impact"] = (
    df["weather_delay"] /
    df["total_delay"]
) * 100


# # Total Delay by Cause

# In[17]:


delay_cols = [
    "carrier_delay",
    "weather_delay",
    "delay_attributed_to_the_nas",
    "security_delay",
    "late_aircraft_delay"
]

delay_sum = df[delay_cols].sum().sort_values()

plt.figure(figsize=(10,5))
sns.barplot(x=delay_sum.values, y=delay_sum.index)
plt.title("Total Delay by Cause")
plt.xlabel("Minutes")
plt.ylabel("Cause")
plt.tight_layout()
plt.show()


# # Monthly Total Delay Trend

# In[18]:


monthly = df.groupby("month")["total_delay"].sum()

plt.figure(figsize=(10,5))
plt.plot(monthly.index, monthly.values, marker="o")
plt.title("Monthly Total Delay Trend")
plt.xlabel("Month")
plt.ylabel("Total Delay")
plt.tight_layout()
plt.show()


# # Top 10 Worst Carriers (Delay Rate)

# In[19]:


carrier_perf = df.groupby("carrier_name")["delay_rate"].mean().sort_values(ascending=False).head(10)

plt.figure(figsize=(10,5))
sns.barplot(x=carrier_perf.values, y=carrier_perf.index)
plt.title("Top 10 Worst Carriers (Delay Rate)")
plt.xlabel("Delay Rate %")
plt.ylabel("Carrier")
plt.tight_layout()
plt.show()


# # Weather Delay vs Total Delay

# In[20]:


plt.figure(figsize=(7,5))
sns.scatterplot(data=df, x="weather_delay", y="total_delay")
plt.title("Weather Delay vs Total Delay")
plt.tight_layout()
plt.show()


# # Top 10 Congested Airports

# In[23]:


airport = df.groupby("airport_name")["number_of_flights_delayed"].sum().sort_values(ascending=False).head(10)

plt.figure(figsize=(10,5))
sns.barplot(x=airport.values, y=airport.index)
plt.title("Top 10 Congested Airports")
plt.xlabel("Delayed Flights")
plt.ylabel("Airport")
plt.tight_layout()
plt.show()


# # Monthly Delay Rate Distribution

# In[25]:


plt.figure(figsize=(12,6))
sns.boxplot(
    x='month',
    y='delay_rate',
    data=df
)

plt.title('Monthly Delay Rate Distribution')
plt.show()


# # Heatmap

# In[29]:


import seaborn as sns
import matplotlib.pyplot as plt

numeric_cols = [
    'number_of_arriving_flights',
    'number_of_flights_delayed',
    'carrier_delay',
    'weather_delay',
    'delay_attributed_to_the_nas',
    'security_delay',
    'late_aircraft_delay',
    'total_delay',
    'delay_rate'
]

corr_matrix = df[numeric_cols].corr()

plt.figure(figsize=(12,8))
sns.heatmap(
    corr_matrix,
    annot=True,
    cmap='coolwarm',
    fmt='.2f'
)

plt.title('Correlation Heatmap')
plt.show()


# # Export the Dataset

# In[31]:


df.to_csv("D:\Project\data analysis project 2\Airline_Delay_Cause_analysis.csv")

