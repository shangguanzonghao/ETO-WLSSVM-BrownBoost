import numpy as np
import scipy.io
import matplotlib.pyplot as plt
import shap
import matplotlib

matplotlib.use('Agg')


model = scipy.io.loadmat('lssvm_model_NCA.mat')
alpha = model['alpha'].flatten()
b = model['b'].flatten()
p_train = model['p_train']
t_train = model['t_train']
type = model['type'].item()
gam = model['gam'].item()
sig2 = model['sig2'].item()


def rbf_kernel(X1, X2, gamma):
    sq_dists = np.sum(X1 ** 2, 1).reshape(-1, 1) + np.sum(X2 ** 2, 1) - 2 * np.dot(X1, X2.T)
    return np.exp(-gamma * sq_dists)


def lssvm_predict(X):
    K = rbf_kernel(X, p_train, sig2)
    return np.dot(K, alpha) + b


plt.rcParams['font.family'] = 'Times New Roman'


background_data = p_train[1:50]
explainer = shap.KernelExplainer(lssvm_predict, background_data)
shap_values = explainer.shap_values(background_data)
feature_names = ['PSDE','SVDE','EeE','ApEn','SpEn','FuzzyEn','PeEn','EnveEn','DE']


explanation = shap.Explanation(
    values=shap_values,
    base_values=np.mean(explainer.expected_value),
    data=background_data,
    feature_names=feature_names
)

path_fig1 = r'C:\Users\Administrator\Pictures\Latex\fig1.png'
path_fig2 = r'C:\Users\Administrator\Pictures\Latex\fig2.png'

plt.figure(1)
shap.plots.bar(explanation)
ax = plt.gca()
yticks = ax.get_yticklabels()
for label in yticks:
    if label.get_text() in feature_names:
        label.set_fontstyle('italic')


ax.xaxis.label.set_weight('bold')
ax.yaxis.label.set_weight('bold')
plt.savefig(path_fig1, format='png',dpi=600)
plt.close()


plt.figure(2)
shap.plots.beeswarm(explanation)

ax = plt.gca()
yticks = ax.get_yticklabels()
for label in yticks:
    if label.get_text() in feature_names:
        label.set_fontstyle('italic')

plt.savefig(path_fig2, format='png',dpi=600)
plt.close()