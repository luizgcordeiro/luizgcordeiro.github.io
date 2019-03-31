<!-- 1.2.1 -->
<div class="definition reference" id="refdefinitioninversesemigroup">
<p><span class="envidentifier">Definition 1.2.1</span>
A <em>semigroup</em> is a set $S$ endowed with an associative binary operation $(s,t)\mapsto st$. A semigroup is
<ol>
	<li> <em>regular</em> if for every $s\in S$ there exists an element $t\in S$, called an <em>inverse</em> of $s$, satisfying $sts=s$ and $tst=t$.</li>
	<li> an <em>inverse semigroup</em> if it is regular and every $s\in S$ admits a unique inverse. In this case we denote it as $s^*$.
	<li> a <em>monoid</em> if it has an <em>identity</em> or <em>unit</em>, that is, an element $1\in S$ (necessarily unique) satisfying $1s=s1=s$ for all $s\in S$.
</ol>
A <em>subsemigroup</em> of a semigroup $S$ is a subset $T\subseteq S$ which is closed under the semigroup operation. A <em>sub-inverse semigroup</em> of an inverse semigroup is a subsemigroup which is closed under inverses.</p>
</div>

<!-- 1.2.2 -->
<div class="reference definition" id="refdefinitionmorphismofsemigroups">
<p><span class="envidentifier">Definition 1.2.2</span>
A <em>morphism</em> of semigroups is a map $\theta:S\to T$ satisfying $\theta(s_1s_2)=\theta(s_1)\theta(s_2)$ for all $s_1,s_2\in S$. Moreover, $\theta$ is an <em>isomorphism</em> if it is invertible and $\theta^{-1}$ is also a morphism.
</div>

<div class="reference remark" id="refremarksubinversesemigroups">
<p><span class="envidentifier">Remark</span>
If $S$ is an inverse semigroup and $T$ is a subsemigroup which is regular, then every element $t\in T$ admits an inverse $t'\in T$. However since inverses are unique in $S$ then $t'=t^*$. Therefore regular sub-semigroups of inverse semigroups are sub-inverse semigroups.
</p>
</div>

	<!-- 1.2.11 -->
<div class="reference example" id="refexamplebisectionsofequivalencerelationarefunctions">
<p><span class="envidentifier">Example 1.2.11</span>
If $R$ is an equivalence relation on a set $X$ (seen as a principal groupoid), then $\operatorname{\bf Bis}(R)$ can be identified with the subsemigroup of $\mathcal{I}(X)$
<div class="equation">\[
\mathcal{J}=\left\{f\in\mathcal{I}(X):\forall x\in\dom(f), (f(x),x)\in R\right\}.
\]</div>
Indeed, the map $\theta:\operatorname{\bf Bis}(R)\to\mathcal{J}$, given by
<div class="equation">\[
\theta_A=\ra\circ(\so|_A)^{-1}:\so(A)\to\ra(A)
\]</div>
is a semigroup morphism with inverse $f\mapsto\operatorname{graph}(f)$. Whenever necessary, we will identify $\operatorname{\bf Bis}(R)$ with $\mathcal{J}$ in this manner.
</p>
<p>
In particular, if $R=X\times X$ then $\mathcal{J}=\mathcal{I}(X)$, so $\operatorname{Bis}(X\times X)$ is isomorphic to $\mathcal{I}(X)$.
</p>
</div>

<!-- 1.2.12 -->
<div class="reference example" id="refexampleginsidebisectionsoftransformationgroupoid">
<p><span class="envidentifier">Example 1.2.12</span>
If $\theta$ is an action of a group $G$ on a set $X$, then the map $g\mapsto\left\{g\right\}\times X$ is an injective morphism (Definition <a class="makeref" data-target="refdefinitionmorphismofsemigroups" href="#definitionmorphismofsemigroups">1.2.2</a>) of $G$ into $\operatorname{\bf{Bis}}(G\ltimes_\theta X)$.
</p>
</div>

<!-- 1.2.14 -->
<div class="reference example" id="refexampleidempotentssets">
<p><span class="envidentifier">Example 1.2.14</span>
Given a set $A$, let $\id_A:A\to A$ be the identity function of $A$. Then if $X$ is a set, the idempotent set of $\mathcal{I}(X)$ is
<div class="equation">\[
E(\mathcal{I}(X))=\left\{\id_A:A\subseteq X\right\}.
\]</div>
Also note that $\id_{A\cap B}=\id_A\id_B$ whenever $A,B\subseteq X$, so by identifying subsets of $X$ with their respective identity functions, the semigroup operation of $\mathcal{I}(X)$ corresponds to intersection of sets. Moreover, $f^*f=\id_{\dom(f)}$ and $ff^*=\id_{\ran(f)}$, so $f^*f$ corresponds to the domain of $f$ and $ff^*$ corresponds to the range of $f$.
</p>
</div>

<!-- 1.2.15 -->
<div class="reference theorem" id="reftheoreminverseiffescommute">
<p><span class="envidentifier">Theorem 1.2.15 <span style="font-weight:normal;">([<a class="makeref" data-target="refMR0466355" href="../0.matters/references.html#MR0466355">88</a>, Theorem 5.1.2], [<a class="makeref" data-target="refMR1694900" href="../0.matters/references.html#MR1694900">108</a>, Theorem 1.1.3])</span></span>
A regular semigroup $S$ is inverse if and only if the elements of $E(S)$ commute. In this case, $E(S)$ is a sub-inverse semigroup of $S$.
</p>

<div class="reference equation" id="refequationpartialisometriesinversesemigroup">\[
\Vert x\Vert=\Vert u(x)\Vert=\Vert u(v(u(x)))\Vert\leq\Vert v(u(x))\Vert\leq\Vert u(x)\Vert\leq\Vert x\Vert\ntag
\]</div>